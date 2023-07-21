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
    
    private var dataSource: DataSource?
    
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
    }
    
    private func setupIU() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    private func loadFilteredGamesSnapshot(filter: String = "") async {
        do {
            let filteredGames = try await gameService.getGameByCategory(category: filter)
            
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(filteredGames)
            
            await dataSource?.apply(snapshot, animatingDifferences: true)
        } catch {
            //displayError(error, title: "No category found, please check the correct parameters")
        }
    }
    
    private func setupDataSource() -> DataSource {
        return DataSource(tableView: tableView) { tableView, indexPath, game in
            let cell = tableView.dequeueReusableCell(withIdentifier: GameCell.identifier, for: indexPath) as! GameCell
            
            cell.configure(game: game, hasDetail: false)
            
            return cell
        }
    }
    
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

}

extension GameSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        let searchValue = searchString?.isEmpty ?? true ? "" : searchString?.lowercased()
        
        Task {
            await self.loadFilteredGamesSnapshot(filter: searchValue!)
        }
    }
}
