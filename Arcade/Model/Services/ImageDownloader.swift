//
//  ImageDownloader.swift
//  Arcade
//
//  Created by Lucas Souza on 14/07/23.
//

import UIKit

enum ImageDownloadError: Error, LocalizedError {
    case invalidImage
    case imageRequestFailed
}

actor ImageDownloader {
    func downloadImage(urlString: String) async throws -> UIImage {
        let url = URL(string: urlString)
        
        if let cachedImage = ImageCache.loadImage(url: url!) {
            return cachedImage
        }
        
        let (data, response) =  try await URLSession.shared.data(from: url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ImageDownloadError.imageRequestFailed
        }
        
        if let image = UIImage(data: data) {
            ImageCache.saveImage(image, url: url!)
            return image
        } else {
            throw ImageDownloadError.invalidImage
        }
    }
    
    func downloadImageAndCrop(urlString: String) async throws -> UIImage {
        let url = URL(string: urlString)
        
        if let cachedImage = ImageCache.loadImage(url: url!) {
            return crop(image: cachedImage)
        }
        
        let (data, response) =  try await URLSession.shared.data(from: url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ImageDownloadError.imageRequestFailed
        }
        
        if let image = UIImage(data: data) {
            ImageCache.saveImage(image, url: url!)
            return crop(image: image)
        } else {
            throw ImageDownloadError.invalidImage
        }
    }
    
    private func crop(image: UIImage) -> UIImage {
        let sourceImage = image

        let sideLength = min(
            sourceImage.size.width,
            sourceImage.size.height
        )

        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0

        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLength,
            height: sideLength
        ).integral

        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!

        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )
        
        return croppedImage
    }
}
