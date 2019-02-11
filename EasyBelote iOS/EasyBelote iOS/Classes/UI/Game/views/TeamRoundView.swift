//
//  TeamRoundView.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 15/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import Reusable
import EasyBelote_Core_iOS

final class TeamRoundView: UIView, NibOwnerLoadable {

    // MARK: IBOutlets

    @IBOutlet private(set) weak var viewTeam: HighlightableView!
    @IBOutlet private weak var labelTeam: UILabel!
    @IBOutlet private weak var imageViewBidder: UIImageView!
    @IBOutlet private(set) weak var textFieldScore: UITextField!
    @IBOutlet private(set) weak var stackViewDeclarations: UIStackView!

    private(set) var declarationButtons = [DeclarationButton]()

    // MARK: Properties

    var isBidder = false {
        didSet {
            labelTeam.textColor = isBidder ? ColorName.easyBeloteRed.color : ColorName.easyBeloteGray.color
            imageViewBidder.isHidden = !isBidder
        }
    }

    var score = -1 {
        didSet {
            textFieldScore.text = score != -1 ? String(describing: score) : ""
        }
    }

    // MARK: Life cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textFieldScore.delegate = self
        textFieldScore.placeholder = L10n.Game.Round.enterScore
    }

}

// MARK: - Configure

extension TeamRoundView {

    func configure(teamName: String, declarations: [Declaration]) {
        labelTeam.text = teamName
        configureDeclarations(declarations: declarations)
    }

    func configure(declarationsSelected: [Declaration]) {
        declarationButtons.forEach {
            $0.configure(isSelected: declarationsSelected.contains($0.declaration))
        }
    }

}

// MARK: - UITextFieldDelegate

extension TeamRoundView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let range = Range(range, in: textField.text ?? ""),
            let scoreString = textField.text?.replacingCharacters(in: range, with: string) else {
            return false
        }

        let score = Int(scoreString)
        return scoreString.isEmpty || (score != nil && score! <= Belote.roundPoints)
    }

}

// MARK: - Declarations

extension TeamRoundView {

    private func configureDeclarations(declarations: [Declaration]) {
        stackViewDeclarations.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        declarations.forEach {
            let button = makeDeclarationButton($0)
            self.declarationButtons.append(button)
            self.addDeclarationButton(button)
        }
    }

    private func makeDeclarationButton(_ declaration: Declaration) -> DeclarationButton {
        let declarationButton = DeclarationButton.loadFromNib()
        declarationButton.declaration = declaration
        return declarationButton
    }

    private func addDeclarationButton(_ button: UIButton) {
        var stackView: UIStackView = (stackViewDeclarations.arrangedSubviews.last as? UIStackView) ?? makeNextStackViewType()
        let currentWidth = stackView.arrangedSubviews.reduce(0) { $0 + (($1 as? UIButton)?.frame.size.width ?? 0) + stackView.spacing }
        let newWidth = stackView.spacing + stackView.spacing + button.frame.size.width
        if currentWidth + newWidth > stackViewDeclarations.frame.size.width {
            stackView = makeNextStackViewType()
        }
        stackView.addArrangedSubview(button)
    }

    private func makeNextStackViewType() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackViewDeclarations.addArrangedSubview(stackView)
        return stackView
    }

}
