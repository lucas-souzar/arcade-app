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
    typealias DataSource = UITableViewDiffableDataSource<SectionGameList, Game>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionGameList, Game>
    
    private var tableView: UITableView!
    private var searchController: UISearchController!
    private var messageNotFound: UILabel!
    private var messageSearchBy: UILabel!
    private var labelsStatckView: UIStackView!
    private var spinner: UIActivityIndicatorView!
    
    private var dataSource: DataSource?
    private var searchTimer: Timer?
    
    private let gameService = GameService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupComponents()
        setupIU()
        setupConstraints()
        
        dataSource = setupDataSource()
        tableView.dataSource = dataSource
    }
    
    private func setupComponents() {
        tableView = UITableView()
        tableView.rowHeight = 60
        tableView.register(GameCell.nib(), forCellReuseIdentifier: GameCell.identifier)
        
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
        view.addSubview(tableView)
        
        labelsStatckView.addArrangedSubview(messageNotFound)
        labelsStatckView.addArrangedSubview(messageSearchBy)
        view.addSubview(labelsStatckView)
        
        view.addSubview(spinner)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
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
    
    private func setupDataSource() -> DataSource {
        return DataSource(tableView: tableView) { tableView, indexPath, game in
            let cell = tableView.dequeueReusableCell(withIdentifier: GameCell.identifier, for: indexPath) as! GameCell
            
            cell.configure(game: game, hasDetail: false)
            
            return cell
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
