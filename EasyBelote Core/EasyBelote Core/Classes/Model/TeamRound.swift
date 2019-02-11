//
//  Team.swift
//  EasyBelote Core iOS
//
//  Created by Tom Baranes on 11/02/2019.
//  Copyright © 2019 sample. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

final public class TeamRound: NSObject {
    public let id: Int
    @objc dynamic public var score = -1
    @objc dynamic public var isBidder: Bool
    @objc dynamic internal(set) public var declarationsObservable = [Int]()

    public var declarations: [Declaration] {
        return declarationsObservable.compactMap { Declaration(rawValue: $0) }
    }

    init(id: Int, isBidder: Bool) {
        self.id = id
        self.isBidder = isBidder
    }
}
