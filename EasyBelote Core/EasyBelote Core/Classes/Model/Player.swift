//
//  Player.swift
//  EasyBelote Core iOS
//
//  Created by Tom Baranes on 11/02/2019.
//  Copyright © 2019 sample. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

final public class Player: Codable, DefaultsSerializable {
    public let id: Int
    public var name = ""

    init(id: Int) {
        self.id = id
    }
}
