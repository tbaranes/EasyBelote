//
//  ViewController.swift
//  EasyBelote
//
//  Created by Tom Baranes on 09/01/2019.
//  Copyright © 2019 EasyBelote. All rights reserved.
//

import UIKit
import EasyBelote_Core_iOS

final class HomeViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet private weak var btnNewGame: UIButton!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        makeActions()
        btnNewGame.setTitle(L10n.Home.newGame, for: .normal)
    }

}

// MARK: - IBActions

extension HomeViewController {

    private func makeActions() {
        btnNewGame.addTarget(self, action: #selector(newGamePressed), for: .touchUpInside)
    }

    @objc
    private func newGamePressed() {
        perform(segue: StoryboardSegue.Main.homeVCToGameVC)
    }

}
