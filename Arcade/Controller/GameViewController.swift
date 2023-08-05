//
//  GameViewController.swift
//  Arcade
//
//  Created by Lucas Souza on 29/07/23.
//

import UIKit

class GameViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Screenshots>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Screenshots>
        
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    private var dataSource: DataSource?
    
    private let gameService = GameService()
    private let imageDownloader = ImageDownloader()
    
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = game.title
        
        dataSource = setupDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = setupLayout()
        
        Task {
            await getOneGameSnapshot()
        }
    }
    
    func setupDataSource() -> DataSource {
        return DataSource(collectionView: collectionView) { collectionView, indexPath, screenshot in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameBannerCell", for: indexPath) as! GameViewCell
            cell.setup(image: nil)
            
            Task {
                if let currentPath = collectionView.indexPath(for: cell), currentPath == indexPath {
                    let image = try await self.imageDownloader.downloadImage(urlString: screenshot.image)
                    cell.setup(image: image)
                }
            }
            
            return cell
        }
    }
    
    func setupLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(190))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 10
            section.contentInsets = .init(top: 10, leading: 15, bottom: 0, trailing: 15)
            
            return section
        }
        return layout
    }
    
    private func getOneGameSnapshot() async {
        do {
            let gameDetail = try await gameService.getGameById(id: game.id)
            
            guard let screenshots = gameDetail.screenshots else {
                return
            }
            
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(screenshots)
            
            descriptionLabel.text = gameDetail.shortDescription
            publisherLabel.text = gameDetail.publisher
            developerLabel.text = gameDetail.developer
            platformLabel.text = gameDetail.platform
            categoryLabel.text = gameDetail.genre
            releaseDateLabel.text = gameDetail.releaseDate
            
            await dataSource?.apply(snapshot, animatingDifferences: true)
        } catch {
            displayError(error, title: "Failed to fetch game details")
        }
    }
    
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

}
