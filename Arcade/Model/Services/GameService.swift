//
//  GameService.swift
//  Arcade
//
//  Created by Lucas Souza on 13/07/23.
//

import Foundation

enum GameApiError: Error, LocalizedError {
    case gameNotFound
    case gameRequestFailed
}

struct GameService {
    
    private var baseURL = URL(string: "https://www.freetogame.com/api/")
    
    func getAllGames() async throws -> [Game] {
        let gamesUrl = baseURL?.appending(path: "games")
        let (data, response) = try await URLSession.shared.data(from: gamesUrl!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GameApiError.gameRequestFailed
        }
        
        let decoder = JSONDecoder()
        let games = try decoder.decode([Game].self, from: data)
        
        return games
    }
    
    func getGameById(id: Int) async throws -> GameDetail {
        let gameUrl = baseURL?.appending(path: "game")
        var components = URLComponents(url: gameUrl!, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "id", value: "\(id)")
        ]
        let byIdUrl = components?.url!
        
        let (data, response) = try await URLSession.shared.data(from: byIdUrl!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GameApiError.gameNotFound
        }
        
        let decoder = JSONDecoder()
        let game = try decoder.decode(GameDetail.self, from: data)
        
        return game
    }
    
}
