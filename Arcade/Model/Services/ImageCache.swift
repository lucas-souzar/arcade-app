//
//  ImageCache.swift
//  Arcade
//
//  Created by Lucas Souza on 14/07/23.
//

import UIKit

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
    
    static func loadImage(url: URL) -> UIImage? {
        return shared.object(forKey: url as NSURL)
    }
    
    static func saveImage(_ image: UIImage, url: URL) {
        shared.setObject(image, forKey: url as NSURL)
    }
}
