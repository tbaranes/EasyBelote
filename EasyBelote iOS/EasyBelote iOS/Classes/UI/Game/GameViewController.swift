//
//  GameViewController.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 11/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import IBAnimatable
import EasyBelote_Core_iOS

final class GameViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet private var labelBidding: UILabel!
    @IBOutlet private var viewPlayers: [PlayerView]!

    @IBOutlet private weak var viewTable: UIView!
    @IBOutlet private weak var labelTeam1: UILabel!
    @IBOutlet private weak var labelScoreTeam1: UILabel!
    @IBOutlet private weak var labelTeam2: UILabel!
    @IBOutlet private weak var labelScoreTeam2: UILabel!

    @IBOutlet private weak var viewScores: UIView!
    @IBOutlet private weak var containerViewHistory: UIView!
    @IBOutlet private weak var btnToggleRoundsHistory: UIButton!
    @IBOutlet private weak var viewTotalScores: UIView!

    private var toggleHistoryTapGestureRecognizer: UITapGestureRecognizer!

    // MARK: Properties

    private var game: Game!
    private var tokens = [NSKeyValueObservation]()
    private weak var delegate: GameContainerDelegate?

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        makeActions()
        makeObservers()

        labelBidding.text = L10n.Game.bidding
    }

    func inject(game: Game, delegate: GameContainerDelegate) {
        self.game = game
        self.delegate = delegate
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

// MARK: - Helpers

extension GameViewController {

    public var isHistoryOpened: Bool {
        btnToggleRoundsHistory.transform != .identity
    }

    private func configureGame() {
        game.teams.reduce([]) { $0 + $1 }.forEach { player in
            self.viewPlayers.first { $0.tag == player.id }?.configure(playerName: player.name)
        }

        labelTeam1.text = game.teams.first?.map { $0.name }.joined(separator: " + ")
        labelTeam2.text = game.teams.last?.map { $0.name }.reversed().joined(separator: " + ")
    }

}

// MARK: - KVO

extension GameViewController {

    private func makeObservers() {
        observeGameState()
        observeDealerId()
        observeRounds()
    }

    private func observeGameState() {
        let token = game.observe(\.gameState, options: [.initial, .new]) { [unowned self] object, _ in
            if object.gameState == GameState.playing.rawValue {
                self.configureGame()
            }
        }
        tokens.append(token)
    }

    private func observeDealerId() {
        let token = game.observe(\.currentDealerId, options: [.initial, .new]) { [unowned self] object, _ in
            self.viewPlayers.forEach {
                $0.isDealer = $0.tag == object.currentDealerId
            }
        }
        tokens.append(token)
    }

    // MARK: - All Rounds

    private func observeRounds() {
        let token = game.observe(\.rounds, options: [.initial, .new]) { [unowned self] _, _ in
            let team1Score = self.game.rounds.reduce(0) { $0 + $1.teamsScore.0 }
            let team2Score = self.game.rounds.reduce(0) { $0 + $1.teamsScore.1 }
            self.makeTotalScore(team1Score: team1Score, team2Score: team2Score)
            if team1Score > 0 || team2Score > 0 {
                self.scoreDidChange(isGameEnded: team1Score >= self.game.nbPoints || team2Score >= self.game.nbPoints)
            }
        }
        tokens.append(token)
    }

    private func makeTotalScore(team1Score: Int, team2Score: Int) {
        labelScoreTeam1.text = String(describing: team1Score)
        labelScoreTeam2.text = String(describing: team2Score)

        [labelTeam1, labelTeam2, labelScoreTeam1, labelScoreTeam2].forEach {
            $0?.textColor = ColorName.easyBeloteGray.color
        }

        if team1Score != team2Score {
            (team1Score > team2Score ? [labelTeam1, labelScoreTeam1] : [labelTeam2, labelScoreTeam2]).forEach {
                $0?.textColor = ColorName.easyBeloteOrange.color
            }
        }
    }

    private func scoreDidChange(isGameEnded: Bool) {
        btnToggleRoundsHistory.isHidden = isGameEnded
        toggleHistoryTapGestureRecognizer.isEnabled = !isGameEnded
        if isGameEnded {
            if !isHistoryOpened {
                toggleHistoryPressed()
            }
            delegate?.startConfetti()
        } else {
            delegate?.stopConfetti()
        }
    }

}

// MARK: - IBActions

extension GameViewController {

    private func makeActions() {
        btnToggleRoundsHistory.addTarget(self, action: #selector(toggleHistoryPressed), for: .touchUpInside)
        toggleHistoryTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                   action: #selector(toggleHistoryPressed))
        viewTotalScores.addGestureRecognizer(toggleHistoryTapGestureRecognizer)

        viewPlayers.forEach {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerPressed(_:)))
            $0.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    @objc
    func toggleHistoryPressed() {
        let isOpening = !isHistoryOpened
        let duration = 0.7
        UIView.animate(withDuration: isOpening ? duration / 2 : duration) {
            let alpha: CGFloat = isOpening ? 0 : 1
            self.labelBidding.alpha = alpha
            self.viewTable.alpha = alpha
            self.containerViewHistory.alpha = alpha == 0 ? 1 : 0
        }

        UIView.animate(withDuration: duration) {
            self.btnToggleRoundsHistory.transform = isOpening ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
            self.viewScores.transform = isOpening ? CGAffineTransform(translationX: 0,
                                                                      y: -self.viewScores.frame.minY) : .identity
            self.delegate?.historyStateDidChange(isOpened: isOpening)
        }
    }

    @objc
    private func playerPressed(_ sender: UITapGestureRecognizer) {
        let round = game.makeNewRound(bidderId: sender.view?.tag ?? -1)
        let roundNavController = StoryboardScene.Game.roundVC.instantiate()
        (roundNavController.topViewController as? RoundViewController)?.inject(game: game, round: round)
        present(roundNavController, animated: true)
    }

}

// MARK: - Navigation

extension GameViewController {

    private func prepare(forSegueIdentifier segueIdentifier: StoryboardSegue.Game, segue: UIStoryboardSegue) {
        switch segueIdentifier {
        case .gameVCEmbedRoundHistory:
            prepare(embedRoundHistory: segue)
        case .gameContainerEmbedNewgameVC, .gameContainerEmbedGameVC:
            break
        }
    }

    private func prepare(embedRoundHistory segue: UIStoryboardSegue) {
        if let roundHistoryVC = segue.destination as? RoundHistoryViewController {
            roundHistoryVC.inject(game: game)
        }
    }

}
