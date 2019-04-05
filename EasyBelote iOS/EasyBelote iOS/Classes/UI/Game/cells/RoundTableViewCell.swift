//
//  RoundTableViewCell.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 15/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import Reusable
import EasyBelote_Core_iOS

final class RoundTableViewCell: UITableViewCell, NibReusable {

    // MARK: IBOutlets

    @IBOutlet private weak var labelTeam1: UILabel!
    @IBOutlet private weak var labelTeam2: UILabel!

    // MARK: Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        subviews.forEach {
            $0.alpha = highlighted ? 0.5 : 1
        }
    }

}

// MARK: - Configure

extension RoundTableViewCell {

    func configure(round: Round) {
        let teamsScore = round.teamsScore
        labelTeam1.text = String(describing: teamsScore.0)
        labelTeam2.text = String(describing: teamsScore.1)
        labelTeam1.textColor = teamsScore.0 > teamsScore.1 ? ColorName.easyBeloteOrange.color : ColorName.easyBeloteGray.color
        labelTeam2.textColor = teamsScore.1 > teamsScore.0 ? ColorName.easyBeloteOrange.color : ColorName.easyBeloteGray.color
    }

}
