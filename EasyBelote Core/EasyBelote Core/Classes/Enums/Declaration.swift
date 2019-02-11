//
//  Declaration.swift
//  EasyBelote Core iOS
//
//  Created by Tom Baranes on 11/02/2019.
//  Copyright © 2019 sample. All rights reserved.
//

import Foundation

public enum Declaration: Int, CaseIterable {
    case belote
    case capot

    case tierce
    case quarte
    case quinte
    case square
    case squareNines
    case squareJacks

    static var permanentDeclarations: [Int] {
        return [Declaration.belote.rawValue, Declaration.capot.rawValue]
    }

    var pointsValue: Int {
        switch self {
        case .belote, .tierce:
            return 20
        case .quarte:
            return 50
        case .quinte, .square:
            return 100
        case .squareNines:
            return 150
        case .squareJacks:
            return 200
        case .capot:
            return 0
        }
    }
}
