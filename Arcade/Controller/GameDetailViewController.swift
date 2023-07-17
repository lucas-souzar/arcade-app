//
//  GameDetailViewController.swift
//  Arcade
//
//  Created by Lucas Souza on 14/07/23.
//

import UIKit

class GameDetailViewController: UIViewController {
    
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameDescriptionLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    private let gameService = GameService()
    private let imageDownloader = ImageDownloader()
    
    var game: Game!
    var gameDetail: GameDetails!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = game.title
        
        Task {
            await getOneGame()
        }
    }
    
    private func getOneGame() async {
        do {
            let gameDetail = try await gameService.getGameById(id: game.id)
            self.gameDetail = gameDetail
            
            await MainActor.run {
                gameDescriptionLabel.text = gameDetail.shortDescription
                publisherLabel.text = gameDetail.publisher
                developerLabel.text = gameDetail.developer
                platformLabel.text = gameDetail.platform
                categoryLabel.text = gameDetail.genre
                releaseDateLabel.text = gameDetail.releaseDate
            }
            
            
            guard let screenshots = gameDetail.screenshots else {
                return
            }
            
            if screenshots.count > 0 {
                let image = try await imageDownloader.downloadImage(urlString: screenshots[0].image)
                print(image)
                await MainActor.run {
                    gameImageView.image = image
                }
            }
        } catch {
            print(error)
        }
    }
    
    func setImage(urlString: String) async {
        Task {
            let image = try await imageDownloader.downloadImage(urlString: urlString)
            gameImageView.image = image
        }
    }
    
}
