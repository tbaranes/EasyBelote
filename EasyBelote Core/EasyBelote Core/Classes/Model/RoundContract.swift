//
//  CoincheRound.swift
//  EasyBelote Core iOS
//
//  Created by Tom Baranes on 27/02/2019.
//  Copyright © 2019 sample. All rights reserved.
//

import Foundation

public final class RoundContract: NSObject {

    // MARK: Properties

    @objc dynamic public var points: Int {
        didSet {
            if points != Belote.capotPoints.value && declarations.contains(.capot) {
                toggleDeclaration(.capot)
            }
        }
    }
    @objc dynamic internal(set) public var declarationsObservable = [Int]()

    public var declarations: [Declaration] {
        return declarationsObservable.compactMap { Declaration(rawValue: $0) }
    }

    var scoreMultiplier: Int {
        return max(1, declarations.reduce(0) { $0 + $1.scoreMultiplier })
    }

    // MARK: Life Cycle

    init(isPlayingCoinche: Bool) {
        points = isPlayingCoinche ? -1 : Belote.biddingSuccess.value
    }
}

// MARK: - Declarations

extension RoundContract {

    public func toggleDeclaration(_ declaration: Declaration) {
        if declarations.contains(declaration) {
            declarationsObservable.removeAll { $0 == declaration.rawValue }
            if declaration == .coinche && declarations.contains(.surcoinche) {
                toggleDeclaration(.surcoinche)
            }
        } else {
            declarationsObservable.append(declaration.rawValue)
            if declaration == .capot {
                points = Belote.capotPoints.value
            }
            if declaration == .surcoinche && !declarations.contains(.coinche) {
                toggleDeclaration(.coinche)
            }
        }
    }

}

