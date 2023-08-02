//
//  GameBannerCell.swift
//  Arcade
//
//  Created by Lucas Souza on 29/07/23.
//

import UIKit

class GameBannerCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    static let identifier = "GameBannerCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func nib() -> UINib {
        UINib.init(nibName: GameCell.identifier, bundle: nil)
    }
}
