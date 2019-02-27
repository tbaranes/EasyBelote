//
//  CoincheView.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 27/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import Reusable
import EasyBelote_Core_iOS

final class CoincheView: UIView, NibOwnerLoadable {

    // MARK: IBOutlets

    @IBOutlet private(set) weak var textFieldContract: UITextField!
    @IBOutlet private(set) weak var stackViewButtons: UIStackView!

    // MARk: Properties

    private(set) var declarationButtons = [DeclarationButton]()

    var contractPoints = -1 {
        didSet {
            textFieldContract.text = contractPoints != -1 ? String(describing: contractPoints) : ""
        }
    }

    // MARK: Life cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        makeDeclarationButton()
        textFieldContract.delegate = self
        textFieldContract.placeholder = L10n.Game.Round.enterContract
    }

    private func makeDeclarationButton() {
        Declaration.coincheContractDeclarations.forEach {
            let btnDeclaration = DeclarationButton.loadFromNib()
            btnDeclaration.declaration = $0
            self.stackViewButtons.addArrangedSubview(btnDeclaration)
            self.declarationButtons.append(btnDeclaration)
        }
    }

}

// MARK: Configure

extension CoincheView {

    func configure(declarationsSelected: [Declaration]) {
        declarationButtons.forEach {
            $0.configure(isSelected: declarationsSelected.contains($0.declaration))
        }
    }

}

// MARK: - UITextFieldDelegate

extension CoincheView: UITextFieldDelegate {

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
        return scoreString.isEmpty || score != nil
    }

}
