//
//  GameDetailViewController.swift
//  Arcade
//
//  Created by Lucas Souza on 05/08/23.
//

import UIKit

class GameDetailViewController: UIViewController {
    enum Section: Int, Hashable {
        case banner
        case description
        case publisher
        case informations
    }
    
    enum Row: Hashable  {
        case image(Int)
        case description
        case publisher
        case header
        case platform
        case category
        case releaseDate
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let gameService = GameService()
    private let imageDownloader = ImageDownloader()
    
    private var dataSource: DataSource?
    private var gameDetails: GameDetail!
    
    var selectedGame: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedGame.title
        
        collectionView.collectionViewLayout = setupLayout()
        
        dataSource = setupDataSource()
        collectionView.dataSource = dataSource
        
        Task {
            await getGameDetails()
        }
    }
    
    private func setupSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.banner, .description, .publisher, .informations])
        
        var screenshotItems: [Row] = []
        gameDetails.screenshots?.forEach({ screenshot in
            screenshotItems.append(Row.image(screenshot.id))
        })
                
        snapshot.appendItems(screenshotItems, toSection: .banner)
        snapshot.appendItems([Row.description], toSection: .description)
        snapshot.appendItems([Row.publisher], toSection: .publisher)
        snapshot.appendItems([Row.header, Row.platform, Row.category, Row.releaseDate], toSection: .informations)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupDataSource() -> DataSource {
        let cellInfoRegistration = UICollectionView.CellRegistration(handler: cellInfoRegistrationHandler)
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, row in
            switch Section(rawValue: indexPath.section) {
            case .banner:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! BannerViewCell
                
                guard let screenshots = self.gameDetails.screenshots else {
                    return cell
                }
                
                Task {
                    if let currentPath = collectionView.indexPath(for: cell), currentPath == indexPath {
                        let image = try await self.imageDownloader.downloadImage(urlString: screenshots[indexPath.item].image)
                        cell.setup(image: image)
                    }
                }
                
                return cell
            case .description:
                let cell = collectionView.dequeueConfiguredReusableCell(using: cellInfoRegistration, for: indexPath, item: row)
                return cell
            case .publisher:
                let cell = collectionView.dequeueConfiguredReusableCell(using: cellInfoRegistration, for: indexPath, item: row)
                return cell
            case .informations:
                let cell = collectionView.dequeueConfiguredReusableCell(using: cellInfoRegistration, for: indexPath, item: row)
                return cell
            default:
                fatalError("Cannot get the section")
            }
        }
    }
    
    private func cellInfoRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        switch Section(rawValue: indexPath.section) {
        case .description:
            var content = cell.defaultContentConfiguration()
            content.text = gameDetails.shortDescription
            
            cell.contentConfiguration = content
        case .publisher:
            var content = cell.defaultContentConfiguration()
            content.text = gameDetails.publisher
            content.textProperties.color = .systemBlue
            content.secondaryText = gameDetails.developer
            content.secondaryTextProperties.color = .systemGray
            
            cell.contentConfiguration = content
        case .informations:
            var content = cell.defaultContentConfiguration()
            content.text = textInfo(for: row)
            content.textProperties.color = .systemGray
            content.secondaryText = text(for: row)
            content.secondaryTextProperties.font = .systemFont(ofSize: 16)
            content.prefersSideBySideTextAndSecondaryText = true
            
            if text(for: row) == nil {
                content.textProperties.font = .boldSystemFont(ofSize: 24)
                content.textProperties.color = .label
            }
            
            cell.contentConfiguration = content
        default:
            fatalError("Could not get section")
        }
    }
    
    private func setupLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch Section(rawValue: sectionIndex) {
            case .banner:
                return self.createPhotoSection()
            case .description:
                return self.createListSection(environment, hasSeparators: false)
            case .publisher:
                return self.createListSection(environment)
            case .informations:
                return self.createListSection(environment, hasHeader: true)
            default: return nil
            }
        }
    }
    
    private func createListSection(_ environment: NSCollectionLayoutEnvironment, hasSeparators: Bool = true, hasHeader: Bool = false) -> NSCollectionLayoutSection? {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = hasSeparators
        
        if hasHeader {
            configuration.headerMode = .firstItemInSection
            configuration.headerTopPadding = 20
        }
        
        let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        return section
    }
    
    private func createPhotoSection() -> NSCollectionLayoutSection {
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
    
    private func getGameDetails() async {
        do {
            gameDetails = try await gameService.getGameById(id: selectedGame.id)
            
            setupSnapshot()
        } catch {
            displayError(error, title: "Failed to fetch game details")
        }
    }
    
    private func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func text(for row: Row) -> String? {
        switch row {
        case .platform: return gameDetails.platform
        case .category: return gameDetails.genre
        case .releaseDate: return gameDetails.releaseDate
        default: return nil
        }
    }
    
    private func textInfo(for row: Row) -> String? {
        switch row {
        case .header: return "Informations"
        case .platform: return "Platform"
        case .category: return "Category"
        case .releaseDate: return "Release Date"
        default: return nil
        }
    }

}
