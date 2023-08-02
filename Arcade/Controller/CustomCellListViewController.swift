//
//  GameListViewController.swift
//  Arcade
//
//  Created by Lucas Souza on 25/07/23.
//

import UIKit

private enum Section: Hashable {
    case main
}

class CustomCellListViewController: UIViewController {
    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, Game>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Game>
    
    private let gameService = GameService()
    
    private var dataSource: DataSource!
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "List with Custom Cells"
        configureHierarchy()
        configureDataSource()
        
        Task {
            await loadGamesSnapshot()
        }
    }
    
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
}

extension CustomCellListViewController {
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension CustomCellListViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    /// - Tag: CellRegistration
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CustomListCell, Game> { (cell, indexPath, item) in
            cell.updateWithItem(item)
            cell.accessories = [.disclosureIndicator()]
        }
        
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Game) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}

extension CustomCellListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// Declare a custom key for a custom `item` property.
fileprivate extension UIConfigurationStateCustomKey {
    static let item = UIConfigurationStateCustomKey("com.apple.ItemListCell.item")
}

// Declare an extension on the cell state struct to provide a typed property for this custom state.
private extension UICellConfigurationState {
    var item: Game? {
        set { self[.item] = newValue }
        get { return self[.item] as? Game }
    }
}

// This list cell subclass is an abstract class with a property that holds the item the cell is displaying,
// which is added to the cell's configuration state for subclasses to use when updating their configuration.
private class ItemListCell: UICollectionViewListCell {
    private var game: Game? = nil
    
    func updateWithItem(_ newItem: Game) {
        guard game != newItem else { return }
        game = newItem
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.item = self.game
        return state
    }
}

private class CustomListCell: ItemListCell {
    
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    private let categoryIconView = UIImageView()
    private let categoryLabel = UILabel()
    private var customViewConstraints: (categoryLabelLeading: NSLayoutConstraint,
                                        categoryLabelTrailing: NSLayoutConstraint,
                                        categoryIconTrailing: NSLayoutConstraint)?
    
    private let imageDownloader = ImageDownloader()
    
    private func setupViewsIfNeeded() {
        // We only need to do anything if we haven't already setup the views and created constraints.
        guard customViewConstraints == nil else { return }
        
        contentView.addSubview(listContentView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categoryIconView)
        listContentView.translatesAutoresizingMaskIntoConstraints = false
        let defaultHorizontalCompressionResistance = listContentView.contentCompressionResistancePriority(for: .horizontal)
        listContentView.setContentCompressionResistancePriority(defaultHorizontalCompressionResistance - 1, for: .horizontal)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = (
            categoryLabelLeading: categoryLabel.leadingAnchor.constraint(greaterThanOrEqualTo: listContentView.trailingAnchor),
            categoryLabelTrailing: categoryIconView.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            categoryIconTrailing: contentView.trailingAnchor.constraint(equalTo: categoryIconView.trailingAnchor)
        )
        NSLayoutConstraint.activate([
            listContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            listContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            listContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryIconView.widthAnchor.constraint(equalToConstant: 40),
            constraints.categoryLabelLeading,
            constraints.categoryLabelTrailing,
            constraints.categoryIconTrailing
        ])
        customViewConstraints = constraints
    }
    
    private var separatorConstraint: NSLayoutConstraint?
    private func updateSeparatorConstraint() {
        guard let textLayoutGuide = listContentView.textLayoutGuide else { return }
        if let existingConstraint = separatorConstraint, existingConstraint.isActive {
            return
        }
        let constraint = separatorLayoutGuide.leadingAnchor.constraint(equalTo: textLayoutGuide.leadingAnchor)
        constraint.isActive = true
        separatorConstraint = constraint
    }
    
    /// - Tag: UpdateConfiguration
    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()
        
        // Configure the list content configuration and apply that to the list content view.
        var content = defaultListContentConfiguration().updated(for: state)
        content.imageProperties.preferredSymbolConfiguration = .init(font: content.textProperties.font, scale: .large)
        content.text = state.item?.title
        content.secondaryText = state.item?.genre
        content.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption1)
        content.secondaryTextProperties.color = .systemGray
        content.image = UIImage(systemName: "gamecontroller.fill")
        content.axesPreservingSuperviewLayoutMargins = []
        listContentView.configuration = content
        
        // Get the list value cell configuration for the current state, which we'll use to obtain the system default
        // styling and metrics to copy to our custom views.
//        let valueConfiguration = UIListContentConfiguration.valueCell().updated(for: state)
        
        // Configure custom image view for the category icon, copying some of the styling from the value cell configuration.
        
        Task {
            categoryIconView.image = await getImg(url: state.item!.thumbnail)
            content.image = await getImg(url: state.item!.thumbnail)
            
            listContentView.configuration = content
        }
        
//        categoryIconView.tintColor = valueConfiguration.imageProperties.resolvedTintColor(for: tintColor)
//        categoryIconView.preferredSymbolConfiguration = .init(font: valueConfiguration.secondaryTextProperties.font, scale: .small)
        
        // Configure custom label for the category name, copying some of the styling from the value cell configuration.
//        categoryLabel.text = state.item?.title
//        categoryLabel.textColor = valueConfiguration.secondaryTextProperties.resolvedColor()
//        categoryLabel.font = valueConfiguration.secondaryTextProperties.font
//        categoryLabel.adjustsFontForContentSizeCategory = valueConfiguration.secondaryTextProperties.adjustsFontForContentSizeCategory
        
        // Update some of the constraints for our custom views using the system default metrics from the configurations.
//        customViewConstraints?.categoryLabelLeading.constant = content.directionalLayoutMargins.trailing
//        customViewConstraints?.categoryLabelTrailing.constant = valueConfiguration.textToSecondaryTextHorizontalPadding
//        customViewConstraints?.categoryIconTrailing.constant = content.directionalLayoutMargins.trailing
        updateSeparatorConstraint()
    }
    
    func getImg(url: String) async -> UIImage {
        do {
            let image = try await imageDownloader.downloadImage(urlString: url)
            return image
        } catch {
            return UIImage(systemName: "gamecontroller.fill")!
        }
    }
}
