//
//  GameCardViewCell.swift
//  Arcade
//
//  Created by Lucas Souza on 02/08/23.
//

import UIKit

class GameCardViewCell: UICollectionViewCell {
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setup(thumbnail: UIImage?, name: String) {
        frameView.layoutIfNeeded()
        frameView.clipsToBounds = true
        frameView.layer.cornerRadius = 10
        
        imageView.image = thumbnail
        imageView.contentMode = .scaleAspectFill
        
        nameLabel.text = name
    }
    
}
