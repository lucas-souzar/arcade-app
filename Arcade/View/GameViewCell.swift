//
//  GameViewCell.swift
//  Arcade
//
//  Created by Lucas Souza on 29/07/23.
//

import UIKit

class GameViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bannerImage: UIImageView!
    
    func setup(image: UIImage?) {
        bannerImage.image = image
        bannerImage.layoutIfNeeded()
        bannerImage.layer.cornerRadius = 10
        bannerImage.contentMode = .scaleAspectFill
    }
    
}
