//
//  Game.swift
//  Arcade
//
//  Created by Lucas Souza on 13/07/23.
//

import Foundation

struct Game: Codable {
    var id: Int
    var title: String
    var thumbnail: String
    var status: String?
    var shortDescription: String
    var description: String?
    var gameUrl: String
    var genre: String
    var platform: String
    var publisher: String
    var developer: String
    var releaseDate: String
    var freetogameProfileUrl: String
    var minimumSystemRequirements: SystemRequirements?
    var screenshots: [Screenshots]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case thumbnail
        case status
        case shortDescription = "short_description"
        case description
        case gameUrl = "game_url"
        case genre
        case platform
        case publisher
        case developer
        case releaseDate = "release_date"
        case freetogameProfileUrl = "freetogame_profile_url"
        case minimumSystemRequirements = "minimum_system_requirements"
        case screenshots
    }
}

extension Game: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
}
