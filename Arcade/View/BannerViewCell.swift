//
//  BannerViewCell.swift
//  Arcade
//
//  Created by Lucas Souza on 05/08/23.
//

import UIKit

class BannerViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setup(image: UIImage?) {
        imageView.image = image
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
    }
    
}
