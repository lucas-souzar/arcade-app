//
//  GameTableViewCell.swift
//  Arcade
//
//  Created by Lucas Souza on 14/07/23.
//

import UIKit

class GameCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var chevronRight: UIImageView!
    
    static let identifier = "GameCell"
    
    private let imageDownloader = ImageDownloader()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        UINib.init(nibName: GameCell.identifier, bundle: nil)
    }
    
    func configure(game: Game, hasDetail: Bool = true) {
        gameTitle.text = game.title
        genre.text = game.genre
        thumbnailImage.image = UIImage(systemName: "gamecontroller.fill")
        thumbnailImage.layer.cornerRadius = 15
        
        if hasDetail == false {
            chevronRight.isHidden = true
        }
        
        Task {
            let image = try await imageDownloader.downloadImage(urlString: game.thumbnail)
            thumbnailImage.image = image
        }
    }
    
}
