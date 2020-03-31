//
//  GameContainerViewController.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 14/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import SAConfettiView
import EasyBelote_Core_iOS

protocol GameContainerDelegate: AnyObject {
    func historyStateDidChange(isOpened: Bool)

    func startConfetti()
    func stopConfetti()
}

final class GameContainerViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet private weak var containerViewNewGame: UIView!
    @IBOutlet private weak var containerViewGame: UIView!
    @IBOutlet private weak var viewConfetti: SAConfettiView!

    // MARK: - Game

    private var game = Game()
    private var tokens = [NSKeyValueObservation]()

    private var newGameVC: NewGameViewController!
    private var gameVC: GameViewController!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        makeObservers()
    }

    deinit {
        tokens.invalidateAll()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
            let segueIdentifier = StoryboardSegue.Game(rawValue: identifier) else {
                return
        }

        prepare(forSegueIdentifier: segueIdentifier, segue: segue)
    }

}

// MARK: - Initialize

extension GameContainerViewController {

    private func configureNavigationBar() {
        let rightBarButton = UIBarButtonItem(image: Asset.genericClose.image,
                                             style: .plain,
                                             target: self,
                                             action: #selector(closePressed))
        navigationItem.rightBarButtonItem = rightBarButton

        if game.gameState == GameState.playing.rawValue {
            makeDealerNavigationBarButton()
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }

    private func makeDealerNavigationBarButton() {
        let leftBarButton = UIBarButtonItem(image: Asset.gameChangeDealer.image,
                                            style: .plain,
                                            target: self,
                                            action: #selector(changeDealerPressed))
        navigationItem.leftBarButtonItem = leftBarButton
    }

}

// MARK: - KVO

extension GameContainerViewController {

    private func makeObservers() {
        observeGameState()
    }

    private func observeGameState() {
        let token = game.observe(\.gameState, options: [.initial, .new]) { [unowned self] _, _ in
            self.configureNavigationBar()
            self.gameStateDidChange()
        }
        tokens.append(token)
    }

    private func gameStateDidChange() {
        let duration = containerViewGame.alpha == 1 && containerViewGame.alpha == 1 ? 0 : 0.2
        UIView.animate(withDuration: duration) {
            self.containerViewNewGame.alpha = self.game.gameState == GameState.configuring.rawValue ? 1 : 0
            self.containerViewGame.alpha = self.game.gameState == GameState.playing.rawValue ? 1 : 0
        }
    }

}

// MARK: - IBActions

extension GameContainerViewController {

    @objc
    private func closePressed() {
        if gameVC.isHistoryOpened && !viewConfetti.isActive() {
            gameVC.toggleHistoryPressed()
        } else {
            dismiss(animated: true)
        }
    }

    @objc
    private func changeDealerPressed() {
        game.moveToNextDealer()
    }

}

// MARK: - GameContainerDelegate

extension GameContainerViewController: GameContainerDelegate {

    func startConfetti() {
        viewConfetti.startConfetti()
        viewConfetti.isHidden = false
    }

    func stopConfetti() {
        viewConfetti.isHidden = true
        viewConfetti.stopConfetti()
    }

    func historyStateDidChange(isOpened: Bool) {
        if isOpened {
            navigationItem.leftBarButtonItem = nil
        } else {
            makeDealerNavigationBarButton()
        }
    }

}

// MARK: - Navigation

extension GameContainerViewController {

    private func prepare(forSegueIdentifier segueIdentifier: StoryboardSegue.Game, segue: UIStoryboardSegue) {
        switch segueIdentifier {
        case .gameContainerEmbedNewgameVC:
            prepare(embedNewGameVC: segue)
        case .gameContainerEmbedGameVC:
            prepare(embedGameVC: segue)
        case .gameVCEmbedRoundHistory:
            break
        }
    }

    private func prepare(embedNewGameVC segue: UIStoryboardSegue) {
        if let newGameVC = segue.destination as? NewGameViewController {
            newGameVC.inject(game: game)
        }
    }

    private func prepare(embedGameVC segue: UIStoryboardSegue) {
        if let gameVC = segue.destination as? GameViewController {
            self.gameVC = gameVC
            gameVC.inject(game: game, delegate: self)
        }
    }

}
