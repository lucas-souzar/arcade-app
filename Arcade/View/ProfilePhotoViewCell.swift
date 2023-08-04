//
//  ProfilePhotoViewCell.swift
//  Arcade
//
//  Created by Lucas Souza on 04/08/23.
//

import UIKit

class ProfilePhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setup(image: String, name: String) {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.image = UIImage(named: image)
        
        nameLabel.text = name
    }
}
