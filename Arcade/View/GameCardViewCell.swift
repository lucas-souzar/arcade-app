//
//  GameCardViewCell.swift
//  Arcade
//
//  Created by Lucas Souza on 02/08/23.
//

import UIKit

class GameCardViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setup(thumbnail: UIImage?, name: String) {
        imageView.image = thumbnail
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        
        nameLabel.text = name
    }
    
}
