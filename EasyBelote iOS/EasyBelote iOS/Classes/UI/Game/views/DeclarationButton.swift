//
//  DeclarationButton.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 15/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import Reusable
import IBAnimatable
import EasyBelote_Core_iOS

final class DeclarationButton: AnimatableButton, NibLoadable {

    var declaration: Declaration! {
        didSet {
            let title: String
            switch declaration! {
            case .belote:
                title = L10n.Game.Round.Declaration.belote
            case .capot:
                title = L10n.Game.Round.Declaration.capot
            case .tierce:
                title = L10n.Game.Round.Declaration.tierce
            case .quarte:
                title = L10n.Game.Round.Declaration.quarte
            case .quinte:
                title = L10n.Game.Round.Declaration.quinte
            case .square:
                title = L10n.Game.Round.Declaration.square
            case .squareNines:
                title = L10n.Game.Round.Declaration.squareNines
            case .squareJacks:
                title = L10n.Game.Round.Declaration.squareJacks
            }
            setTitle(title.uppercased(), for: .normal)
        }
    }

    func configure(isSelected: Bool) {
        backgroundColor = isSelected ? ColorName.easyBeloteRed.color : UIColor.black.withAlphaComponent(0.2)
    }

}
