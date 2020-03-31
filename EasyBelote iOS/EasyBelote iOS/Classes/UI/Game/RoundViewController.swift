//
//  RoundViewController.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 15/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import EasyBelote_Core_iOS

final class RoundViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet private var viewCoinche: CoincheView!
    @IBOutlet private var viewCoincheSeparator: UIView!
    @IBOutlet private var viewTeamsRound: [TeamRoundView]!
    @IBOutlet private weak var btnSaveRound: UIButton!

    // MARK: Properties

    private var game: Game!
    private var round: Round!
    private var tokens = [NSKeyValueObservation]()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureGame()

        makeActions()
        makeObservers()
        btnSaveRound.setTitle(L10n.Game.Round.save, for: .normal)
        if !game.isPlayingCoinche {
            viewCoinche.removeFromSuperview()
            viewCoincheSeparator.removeFromSuperview()
        }

        if round.contract.points == -1 {
            viewCoinche.textFieldContract.becomeFirstResponder()
        } else if round.teamsScore.0 == -1 && round.teamsScore.1 == -1 {
            viewTeamsRound.first { $0.isBidder }?.textFieldScore.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewCoinche.textFieldContract.resignFirstResponder()
        viewTeamsRound.forEach {
            $0.textFieldScore.resignFirstResponder()
        }
    }

    func inject(game: Game, round: Round) {
        self.game = game
        self.round = round
    }

    deinit {
        tokens.invalidateAll()
    }

}

// MARK: - Initialize

extension RoundViewController {

    private func configureNavigationBar() {
        let rightBarButton = UIBarButtonItem(image: Asset.genericClose.image,
                                             style: .plain,
                                             target: self,
                                             action: #selector(closePressed))
        rightBarButton.tintColor = ColorName.easyBeloteGray.color
        navigationItem.rightBarButtonItem = rightBarButton
    }

    private func configureGame() {
        viewCoinche.configure(declarationsSelected: round.contract.declarations)
        game.teams.enumerated().forEach { idx, players in
            let teamName = players.map { $0.name }.joined(separator: " + ")
            let viewTeamRound = viewTeamsRound.first { $0.tag == idx }
            viewTeamRound?.configure(teamName: teamName, declarations: game.availableDeclarations)
            viewTeamRound?.configure(declarationsSelected: [])
        }
    }

    private func configureSaveButton() {
        let areScoresValid = viewTeamsRound.allSatisfy { $0.score != -1 }
        if game.isPlayingCoinche {
            btnSaveRound.isEnabled = areScoresValid && viewCoinche.contractPoints >= 0
        } else {
            btnSaveRound.isEnabled = areScoresValid
        }
    }

}

// MARK: - Observers

extension RoundViewController {

    private func makeObservers() {
        observeContractPoints()
        observeContractDeclarations()
        round.teams.forEach {
            self.observeBidderId($0)
            self.observeTeamRoundScore($0)
            self.observeTeamRoundDeclarations($0)
        }
    }

    private func observeContractPoints() {
        let token = round.contract.observe(\.points, options: [.initial, .new]) { [unowned self] object, _ in
            self.viewCoinche.contractPoints = object.points
            self.configureSaveButton()
        }
        tokens.append(token)
    }

    private func observeContractDeclarations() {
        let token = round.contract.observe(\.declarationsObservable,
                                           options: [.initial, .new]) { [unowned self] object, _ in
            self.viewCoinche.configure(declarationsSelected: object.declarations)
        }
        tokens.append(token)
    }

    private func observeBidderId(_ teamRound: TeamRound) {
        let token = teamRound.observe(\.isBidder, options: [.initial, .new]) { [unowned self] object, _ in
            self.viewTeamsRound.first { $0.tag == object.id }?.isBidder = object.isBidder
        }
        tokens.append(token)
    }

    private func observeTeamRoundScore(_ teamRound: TeamRound) {
        let token = teamRound.observe(\.score, options: [.initial, .new]) { [unowned self] object, _ in
            self.viewTeamsRound.first { $0.tag == object.id }?.score = object.score
            self.configureSaveButton()
        }
        tokens.append(token)
    }

    private func observeTeamRoundDeclarations(_ teamRound: TeamRound) {
        let token = teamRound.observe(\.declarationsObservable, options: [.initial, .new]) { [unowned self] object, _ in
            self.viewTeamsRound.first { $0.tag == object.id }?.configure(declarationsSelected: object.declarations)
        }
        tokens.append(token)
    }

}

// MARK: - IBActions

extension RoundViewController {

    private func makeActions() {
        viewCoinche.textFieldContract.addTarget(self,
                                                action: #selector(textFieldContractEditingChanged(_:)),
                                                for: .editingChanged)
        viewCoinche.declarationButtons.forEach { btn in
            btn.addTarget(self, action: #selector(contractDeclarationPressed(_:)), for: .touchUpInside)
        }

        viewTeamsRound.forEach {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bidderPressed(_:)))
            $0.viewTeam.addGestureRecognizer(tapGestureRecognizer)
            $0.textFieldScore.addTarget(self, action: #selector(textFieldScoreEditingChanged(_:)), for: .editingChanged)
            $0.textFieldScore.addTarget(self, action: #selector(textFieldScoreEditingDidEnd(_:)), for: .editingDidEnd)
            $0.declarationButtons.forEach { btn in
                btn.addTarget(self, action: #selector(declarationPressed(_:)), for: .touchUpInside)
            }
        }
        btnSaveRound.addTarget(self, action: #selector(saveRoundPressed), for: .touchUpInside)
    }

    @objc
    private func closePressed() {
        dismiss(animated: true)
    }

    // MARK: Contract

    @objc
    private func textFieldContractEditingChanged(_ textField: UITextField) {
        let points = Int(textField.text ?? "")
        round.contract.points = points ?? -1
    }

    @objc
    private func contractDeclarationPressed(_ btn: DeclarationButton) {
        round.contract.toggleDeclaration(btn.declaration)
    }

    // MARK: Game

    @objc
    private func saveRoundPressed() {
        if game.rounds.contains(round) {
            game.updateRound(round)
        } else {
            game.validateRound(round)
        }
        closePressed()
    }

    @objc
    private func bidderPressed(_ sender: UITapGestureRecognizer) {
        round.changeBidderId(viewTeamsRound.first { $0.viewTeam == sender.view }?.tag ?? -1)
    }

    @objc
    private func declarationPressed(_ btn: DeclarationButton) {
        let teamId = viewTeamsRound.first { $0.declarationButtons.contains(btn) }?.tag ?? 0
        round.toggleDeclaration(btn.declaration, to: teamId)
    }

    // MARK: Scoring

    @objc
    private func textFieldScoreEditingChanged(_ textField: UITextField) {
        computeScore(from: textField, checkInside: false)
    }

    @objc
    private func textFieldScoreEditingDidEnd(_ textField: UITextField) {
        computeScore(from: textField, checkInside: true)
    }

    private func computeScore(from textField: UITextField, checkInside: Bool) {
        guard let tag = viewTeamsRound.first(where: { $0.textFieldScore == textField })?.tag else {
            return
        }

        let score = Int(textField.text ?? "")
        if tag == 0 {
            round.makeScore(team1Score: score, team2Score: nil, checkInside: checkInside)
        } else {
            round.makeScore(team1Score: nil, team2Score: score, checkInside: checkInside)
        }
    }

}
