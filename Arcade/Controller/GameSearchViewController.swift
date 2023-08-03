//
//  GameSearchViewController.swift
//  Arcade
//
//  Created by Lucas Souza on 19/07/23.
//

import UIKit

enum SectionGameList: CaseIterable {
    case main
}

class GameSearchViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<SectionGameList, Game>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionGameList, Game>
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var searchController: UISearchController!
    private var messageNotFound: UILabel!
    private var messageSearchBy: UILabel!
    private var labelsStatckView: UIStackView!
    private var spinner: UIActivityIndicatorView!
    
    private var dataSource: DataSource?
    private var searchTimer: Timer?
    
    private let gameService = GameService()
    private let imageDownloader = ImageDownloader()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupComponents()
        setupIU()
        setupConstraints()
        
        dataSource = setupDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = setupLayout()
        collectionView.delegate = self
    }
    
    private func setupComponents() {
        searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        messageNotFound = UILabel()
        messageNotFound.text = "No recent searches..."
        messageNotFound.textColor = .arcadeText
        messageNotFound.font = .boldSystemFont(ofSize: 20)
        messageNotFound.numberOfLines = 0
        messageNotFound.textAlignment = .center
        
        messageSearchBy = UILabel()
        messageSearchBy.text = "Search by category."
        messageSearchBy.textColor = .arcadeText
        messageSearchBy.font = .systemFont(ofSize: 14)
        
        labelsStatckView = UIStackView()
        labelsStatckView.axis = .vertical
        labelsStatckView.alignment = .center
        labelsStatckView.spacing = 6
        
        spinner = UIActivityIndicatorView(style: .large)
    }
    
    private func setupIU() {
        labelsStatckView.addArrangedSubview(messageNotFound)
        labelsStatckView.addArrangedSubview(messageSearchBy)
        view.addSubview(labelsStatckView)
        
        view.addSubview(spinner)
    }
    
    private func setupConstraints() {
        labelsStatckView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelsStatckView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            labelsStatckView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            labelsStatckView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
    }
    
    private func loadFilteredGamesSnapshot(filter: String = "") async {
        spinner.startAnimating()
        
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems([])
        
        guard !filter.isEmpty else {
            
            await dataSource?.apply(snapshot, animatingDifferences: true)
            spinner.stopAnimating()
            
            labelsStatckView.isHidden = false
            messageNotFound.text = "No recent searches..."
            return
        }
        
        do {
            labelsStatckView.isHidden = true
            
            let filteredGames = try await gameService.getGameByCategory(category: filter)
 
            snapshot.appendItems(filteredGames)
            
            spinner.stopAnimating()
            await dataSource?.apply(snapshot, animatingDifferences: true)
        } catch {
            await dataSource?.apply(snapshot, animatingDifferences: true)
            spinner.stopAnimating()
            
            labelsStatckView.isHidden = false
            messageNotFound.text = "No category found, please check the correct parameters..."
        }
    }

}

extension GameSearchViewController {
    func setupDataSource() -> DataSource {
        return DataSource(collectionView: collectionView) { collectionView, indexPath, game in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardGameCell", for: indexPath) as! GameCardViewCell
            cell.setup(thumbnail: nil, name: "")
            
            Task {
                if let currentPath = collectionView.indexPath(for: cell), currentPath == indexPath {
                    let image = try await self.imageDownloader.downloadImage(urlString: game.thumbnail)
                    cell.setup(thumbnail: image, name: game.title)
                }
            }
            
            return cell
        }
    }
    
    func setupLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 5, leading: 5, bottom: 0, trailing: 5)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 5, leading: 5, bottom: 0, trailing: 5)
            
            return section
        }
        return layout
    }
}

extension GameSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let game = dataSource?.itemIdentifier(for: indexPath) else { return false }
        
        performSegue(withIdentifier: "GameCardSegue", sender: game)
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameCardSegue", let gameVC = segue.destination as? GameViewController, let game = sender as? Game {
            gameVC.game = game
        }
    }
}

extension GameSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchTimer?.invalidate()
        
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            Task {
                await self.loadFilteredGamesSnapshot(filter: searchText)
            }
        })
                
    }
}
