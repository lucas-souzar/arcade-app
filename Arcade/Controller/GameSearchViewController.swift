//
//  GameSearchViewController.swift
//  Arcade
//
//  Created by Lucas Souza on 19/07/23.
//

import UIKit

class GameSearchViewController: UIViewController {
    
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupComponents()
        setupIU()
        setupConstraints()
    }
    
    private func setupComponents() {
        tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GameViewCell")
    }
    
    private func setupIU() {
        self.view.backgroundColor = .blue
        self.view.addSubview(tableView)
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

}
