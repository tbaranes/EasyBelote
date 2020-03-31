//
//  Defaults.swift
//  EasyBelote Core iOS
//
//  Created by Tom Baranes on 31/03/2020.
//  Copyright © 2020 sample. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

// MARK: - DefaultsKeys

extension DefaultsKeys {
    var userThemeName: DefaultsKey<String?> { .init("userThemeName") }

    var players: DefaultsKey<[Player]?> { .init("teams") }
    var nbPoints: DefaultsKey<Int> { .init("nb_points", defaultValue: 1001) }
    var isDeclarationsEnabled: DefaultsKey<Bool> { .init("is_declarations_enabled", defaultValue: false) }
    var isPlayingCoinche: DefaultsKey<Bool> { .init("is_coinche", defaultValue: false) }
    var isRotationTurnClockwise: DefaultsKey<Bool> { .init("is_rotation_turn_clockwise", defaultValue: false) }
}
