//
//  GameDetails.swift
//  Arcade
//
//  Created by Lucas Souza on 17/07/23.
//

import Foundation

struct GameDetail: Codable {
    var id: Int
    var title: String
    var thumbnail: String
    var status: String
    var shortDescription: String
    var description: String
    var gameUrl: String
    var genre: String
    var platform: String
    var publisher: String
    var developer: String
    var releaseDate: String
    var freetogameProfileUrl: String
    var minimumSystemRequirements: SystemRequirements
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
