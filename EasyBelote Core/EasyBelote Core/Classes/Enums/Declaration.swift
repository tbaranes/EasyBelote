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

    case coinche
    case surcoinche

    case tierce
    case quarte
    case quinte
    case square
    case squareNines
    case squareJacks

    static var permanentDeclarations: [Int] {
        return [Declaration.belote.rawValue, Declaration.capot.rawValue]
    }

    static public var coincheContractDeclarations: [Declaration] {
        return [Declaration.capot, Declaration.coinche, Declaration.surcoinche]
    }

    static var teamDeclarations: [Declaration] {
        var teamDeclarations = Declaration.allCases
        teamDeclarations.removeAll { $0 == .coinche || $0 == .surcoinche }
        return teamDeclarations
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
        case .capot, .coinche, .surcoinche:
            return 0
        }
    }

    var scoreMultiplier: Int {
        switch self {
        case .coinche, .surcoinche:
            return 2
        default:
            return 0
        }
    }
}
