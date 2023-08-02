//
//  Screenshots.swift
//  Arcade
//
//  Created by Lucas Souza on 13/07/23.
//

import Foundation

struct Screenshots: Codable {
    var id: Int
    var image: String
}

extension Screenshots: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Screenshots, rhs: Screenshots) -> Bool {
        return lhs.id == rhs.id
    }
}
