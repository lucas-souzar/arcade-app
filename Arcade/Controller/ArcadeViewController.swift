//
//  ArcadeViewController.swift
//  Arcade
//
//  Created by Lucas Souza on 13/07/23.
//

import UIKit

enum Section: CaseIterable {
    case main
}

class ArcadeViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, Game>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Game>
    
    @IBOutlet weak var tableView: UITableView!
    
    private let gameService = GameService()
    
    private var dataSource: DataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()

        Task {
            await loadGamesSnapshot()
        }
    }
    
    private func setupTableView() {
        dataSource = setupDataSource()
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(GameCell.nib(), forCellReuseIdentifier: GameCell.identifier)
        
        tableView.rowHeight = 60
        tableView.layer.cornerRadius = 15
    }
    
    //MARK: - Snapshot method
    func loadGamesSnapshot() async {
        do {
            let games = try await gameService.getAllGames()
            
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(games)
            
            await dataSource?.apply(snapshot, animatingDifferences: true)
        } catch {
            print(error)
        }
    }
    
    //MARK: - Data source method
    func setupDataSource() -> DataSource {
        return DataSource(tableView: tableView) { tableView, indexPath, game in
            let cell = tableView.dequeueReusableCell(withIdentifier: GameCell.identifier, for: indexPath) as! GameCell
            
            cell.configure(game: game)
            
            return cell
        }
    }

}

extension ArcadeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = dataSource?.itemIdentifier(for: indexPath)
        
        performSegue(withIdentifier: "GameDetailSegue", sender: game)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameDetailSegue", let gameDetailVC = segue.destination as? GameDetailViewController, let game = sender as? Game {
            gameDetailVC.game = game
        }
    }
}
