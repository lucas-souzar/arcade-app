//
//  GameListViewController.swift
//  Arcade
//
//  Created by Lucas Souza on 24/07/23.
//

import UIKit

class GameListViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Game>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Game>
    
    private let gameService = GameService()
    private let imageDownloader = ImageDownloader()
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Arcade"
        
        let listLayout = listLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
                
        dataSource = setupDataSource()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        Task {
            await loadGamesSnapshot()
        }
    }
    
    //MARK: - Snapshot method
    func loadGamesSnapshot() async {
        do {
            let games = try await gameService.getAllGames()
            
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(games)
                        
            await dataSource?.apply(snapshot, animatingDifferences: true)
        } catch {
            displayError(error, title: "Failed to fetch game list")
        }
    }
    
    //MARK: - Data source methods
    func setupDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, game in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: game)
            return cell
        }
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, game: Game) {
        var content = cell.defaultContentConfiguration()
        content.text = game.title
        content.secondaryText = game.genre
        content.secondaryTextProperties.color = .systemGray
        content.image = UIImage(systemName: "gamecontroller.fill")
        content.imageProperties.tintColor = .systemGray2
        content.imageProperties.maximumSize = .init(width: 40, height: 40)
        content.imageProperties.cornerRadius = 15

        cell.contentConfiguration = content
        
        Task {
            if let currentPath = collectionView.indexPath(for: cell), currentPath == indexPath {
                content.image = try await imageDownloader.downloadImageAndCrop(urlString: game.thumbnail)
                cell.contentConfiguration = content
            }
        }

        cell.accessories = [
            .disclosureIndicator()
        ]
    }
    
    //MARK: - Layout method
    private func listLayout() -> UICollectionViewCompositionalLayout {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension GameListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let game = dataSource?.itemIdentifier(for: indexPath) else { return false }
        
        performSegue(withIdentifier: "GameViewSegue", sender: game)
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameViewSegue", let gameVC = segue.destination as? GameDetailViewController, let game = sender as? Game {
            gameVC.selectedGame = game
        }
    }
}
