//
//  User.swift
//  Arcade
//
//  Created by Lucas Souza on 02/08/23.
//

import Foundation

struct User {
    var name: String
    var email: String
    var phone: String
    var dateOfBirth: String
    var image: String
    var nickName: String
}

extension User: Hashable {}

extension User {
    static var userLogged = User(
        name: "Lucas Souza",
        email: "lucassouza@email.com",
        phone: "+55 (92)98123-5676",
        dateOfBirth: "26/10/1998",
        image: "character",
        nickName: "LucasFly"
    )
}
