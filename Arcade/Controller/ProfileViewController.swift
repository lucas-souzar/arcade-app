//
//  ProfileViewController.swift
//  Arcade
//
//  Created by Lucas Souza on 04/08/23.
//

import UIKit

class ProfileViewController: UIViewController {
    enum Section: Int, Hashable {
        case photo
        case info
        case logout
    }
    
    enum Row: String, Hashable  {
        case image
        case name = "Name"
        case email = "E-mail"
        case phone = "Phone number"
        case dateOfBirth = "Date of birth"
        case logout = "Sing out"
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: DataSource?
    private var userLogged: User = User.userLogged
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = setupLayout()
        
        dataSource = setupDataSource()
        collectionView.dataSource = dataSource
        
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.photo, .info, .logout])
        
        snapshot.appendItems([Row.image], toSection: .photo)
        
        snapshot.appendItems([Row.name, Row.email, Row.phone, Row.dateOfBirth], toSection: .info)
        
        snapshot.appendItems([Row.logout], toSection: .logout)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupDataSource() -> DataSource {
        let cellInfoRegistration = UICollectionView.CellRegistration(handler: cellInfoRegistrationHandler)
        let cellLogoutRegistration = UICollectionView.CellRegistration(handler: cellLogoutRegistrationHandler)
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, row in
            switch Section(rawValue: indexPath.section) {
            case .photo:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileViewCell", for: indexPath) as! ProfilePhotoViewCell
                cell.setup(image: self.userLogged.image, name: self.userLogged.nickName)
                return cell
            case .info:
                let cell = collectionView.dequeueConfiguredReusableCell(using: cellInfoRegistration, for: indexPath, item: row)
                return cell
            case .logout:
                let cell = collectionView.dequeueConfiguredReusableCell(using: cellLogoutRegistration, for: indexPath, item: row)
                return cell
            default:
                fatalError("Cannot get the section")
            }
        }
    }
    
    private func cellInfoRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        var content = cell.defaultContentConfiguration()
        content.text = row.rawValue
        content.secondaryText = text(for: row)
        content.secondaryTextProperties.color = .systemGray
        content.secondaryTextProperties.font = .systemFont(ofSize: 14)
        content.prefersSideBySideTextAndSecondaryText = true

        cell.contentConfiguration = content
    }
    
    private func cellLogoutRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        var content = cell.defaultContentConfiguration()
        content.text = row.rawValue
        content.textProperties.alignment = .center
        content.textProperties.color = .systemRed
        
        cell.contentConfiguration = content
    }
    
    private func setupLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch Section(rawValue: sectionIndex) {
            case .photo:
                return self.createPhotoSection()
            case .info:
                return self.createListSection(environment)
            case .logout:
                return self.createListSection(environment)
            default: return nil
            }
        }
    }
    
    private func createListSection(_ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        return section
    }
    
    private func createPhotoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(140))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func text(for row: Row) -> String? {
        switch row {
        case .name: return userLogged.name
        case .email: return userLogged.email
        case .phone: return userLogged.phone
        case .dateOfBirth: return userLogged.dateOfBirth
        default: return nil
        }
    }

}
