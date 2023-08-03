//
//  UIColor+Arcade.swift
//  Arcade
//
//  Created by Lucas Souza on 24/07/23.
//

import UIKit

extension UIColor {
    static var arcadeListCellBackground: UIColor {
        UIColor(named: "ArcadeListCellBackground") ?? .secondarySystemBackground
    }
    
    static var arcadeText: UIColor {
        UIColor(named: "ArcadeText") ?? .systemGray
    }
    
    static var arcadeTextInvert: UIColor {
        UIColor(named: "ArcadeTextInvert") ?? .systemGray
    }
}
