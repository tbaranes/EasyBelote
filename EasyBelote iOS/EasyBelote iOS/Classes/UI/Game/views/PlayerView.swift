//
//  PlayerView.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 15/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import Reusable

final class PlayerView: HighlightableView, NibOwnerLoadable {

    // MARK: IBOutlets

    @IBOutlet private weak var imageViewDealer: UIImageView!
    @IBOutlet private weak var labelPlayer: UILabel!

    // MARK: Properties

    var isDealer = false {
        didSet {
            imageViewDealer.isHidden = !isDealer
        }
    }

    // MARK: Life cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

// MARK: - Configure

extension PlayerView {

    func configure(playerName: String) {
        labelPlayer.text = playerName
    }

}
