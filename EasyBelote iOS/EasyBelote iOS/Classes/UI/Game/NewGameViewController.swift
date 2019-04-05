//
//  NewGameViewController.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 11/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import EasyBelote_Core_iOS

final class NewGameViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet private var viewPlayers: [UIView]!
    @IBOutlet private var labelPlayers: [UILabel]!
    @IBOutlet private var textFieldPlayers: [UITextField]!

    @IBOutlet private weak var labelNbPoints: UILabel!
    @IBOutlet private weak var textFieldNbPoints: UITextField!

    @IBOutlet private weak var labelDeclarations: UILabel!
    @IBOutlet private weak var switchDeclarations: UISwitch!

    @IBOutlet private weak var labelCoinche: UILabel!
    @IBOutlet private weak var switchCoinche: UISwitch!

    @IBOutlet private weak var btnStartGame: UIButton!

    // MARK: Properties

    private var game: Game!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        makeActions()
        configureInterface()
        configureGame()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textFieldPlayers.forEach {
            $0.resignFirstResponder()
        }
    }

    func inject(game: Game) {
        self.game = game
    }

}

// MAKR: - Initialize

extension NewGameViewController {

    private func configureInterface() {
        labelPlayers.forEach {
            switch $0.tag {
            case 0: $0.text = L10n.NewGame.Players.you.uppercased()
            case 3: $0.text = L10n.NewGame.Players.onLeft.uppercased()
            case 2: $0.text = L10n.NewGame.Players.yourPartner.uppercased()
            case 1: $0.text = L10n.NewGame.Players.onRight.uppercased()
            default: break
            }
        }

        textFieldPlayers.forEach {
            $0.placeholder = L10n.NewGame.Players.placeholder
            $0.delegate = self
        }

        labelNbPoints.text = L10n.NewGame.nbPoints.uppercased()
        textFieldNbPoints.placeholder = L10n.NewGame.nbPointsPlaceholder

        labelDeclarations.text = L10n.NewGame.declarations.uppercased()
        btnStartGame.isEnabled = game.canStartGame

        labelCoinche.text = L10n.NewGame.coinche.uppercased()
        btnStartGame.setTitle(L10n.NewGame.startGame, for: .normal)
    }

    private func configureGame() {
        textFieldNbPoints.text = String(describing: game.nbPoints)
        game.allPlayers.forEach { player in
            self.textFieldPlayers.first { $0.tag == player.id }?.text = player.name
        }
        switchDeclarations.isOn = game.isDeclarationsEnabled
        switchCoinche.isOn = game.isPlayingCoinche
    }

}

// MARK: - IBActions

extension NewGameViewController {

    private func makeActions() {
        viewPlayers.forEach {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewPlayerPressed(_:)))
            $0.addGestureRecognizer(tapGestureRecognizer)
        }

        textFieldPlayers.forEach {
            $0.addTarget(self, action: #selector(playerNameEditingChanged(_:)), for: .editingChanged)
        }

        textFieldNbPoints.addTarget(self, action: #selector(nbPointsEditingChanged(_:)), for: .editingChanged)
        switchDeclarations.addTarget(self, action: #selector(declarationsValueChanged), for: .valueChanged)
        switchCoinche.addTarget(self, action: #selector(coincheValueChanged), for: .valueChanged)
        btnStartGame.addTarget(self, action: #selector(startGamePressed), for: .touchUpInside)
    }

    @objc
    private func viewPlayerPressed(_ sender: UITapGestureRecognizer) {
        (sender.view?.subviews.first { $0 as? UITextField != nil } as? UITextField )?.becomeFirstResponder()
    }

    @objc
    private func playerNameEditingChanged(_ textField: UITextField) {
        game.allPlayers[textField.tag].name = textField.text?.uppercased() ?? ""
        btnStartGame.isEnabled = game.canStartGame
    }

    @objc
    private func nbPointsEditingChanged(_ textField: UITextField) {
        game.nbPoints = Int(textField.text ?? "1001") ?? 1001
    }

    @objc
    private func declarationsValueChanged(_ sender: UISwitch) {
        game.isDeclarationsEnabled = sender.isOn
    }

    @objc
    private func coincheValueChanged(_ sender: UISwitch) {
        game.isPlayingCoinche = sender.isOn
    }

    @objc
    private func startGamePressed() {
        game.startGame()
    }

}

// MARK: - UITextFieldDelegate

extension NewGameViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTextField: UITextField?
        if btnStartGame.isEnabled {
            nextTextField = nil
        } else {
            nextTextField = textFieldPlayers.first { $0.tag == textField.tag + 1 }
        }
        textField.resignFirstResponder()
        nextTextField?.becomeFirstResponder()
        return true
    }

}
