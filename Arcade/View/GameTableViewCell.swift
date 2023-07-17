//
//  GameTableViewCell.swift
//  Arcade
//
//  Created by Lucas Souza on 14/07/23.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var gameTitleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    static let identifier = "GameTableViewCell"
    
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
        UINib.init(nibName: GameTableViewCell.identifier, bundle: nil)
    }
    
    func configure(game: Game) {
        gameTitleLabel.text = game.title
        genreLabel.text = game.genre
        thumbnailImageView.image = UIImage(systemName: "gamecontroller.fill")
        thumbnailImageView.layer.cornerRadius = 15
        
        Task {
            let image = try await imageDownloader.downloadImage(urlString: game.thumbnail)
            thumbnailImageView.image = image
        }
    }
    
}
