//
//  GameDetail.swift
//  Arcade
//
//  Created by Lucas Souza on 14/07/23.
//

import Foundation

// MARK: - Welcome
struct GameDetaildd: Codable {
    let id: Int
    let title, thumbnail, status, shortDescription: String
    let description, genre, platform, publisher: String
    let developer, releaseDate: String
    let freetogameProfileURL: String
    let minimumSystemRequirements: MinimumSystemRequirements
    let screenshots: [Screenshot]

    enum CodingKeys: String, CodingKey {
        case id, title, thumbnail, status
        case shortDescription = "short_description"
        case description, genre, platform, publisher, developer
        case releaseDate = "release_date"
        case freetogameProfileURL = "freetogame_profile_url"
        case minimumSystemRequirements = "minimum_system_requirements"
        case screenshots
    }
}

// MARK: - MinimumSystemRequirements
struct MinimumSystemRequirements: Codable {
    let os, processor, memory, graphics: String
    let storage: String
}

// MARK: - Screenshot
struct Screenshot: Codable {
    let id: Int
    let image: String
}
