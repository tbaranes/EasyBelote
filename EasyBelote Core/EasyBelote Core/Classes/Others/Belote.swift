//
//  Belote.swift
//  EasyBelote Core iOS
//
//  Created by Tom Baranes on 15/02/2019.
//  Copyright © 2019 sample. All rights reserved.
//

import Foundation

public enum Belote {
    case roundPoints
    case biddingSuccess
    case belotePoints
    case capotPoints

    case smallestCoincheContract
    case coincheMultiplier
    case surcoincheMultiplier

    public var value: Int {
        switch self {
        case .roundPoints:
            return 162
        case .biddingSuccess:
            return 82
        case .belotePoints:
            return 20
        case .capotPoints:
            return 252
        case .smallestCoincheContract:
            return 80
        case .coincheMultiplier:
            return 2
        case .surcoincheMultiplier:
            return 2
        }
    }
}
