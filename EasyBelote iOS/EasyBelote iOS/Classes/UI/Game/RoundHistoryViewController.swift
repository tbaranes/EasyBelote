//
//  RoundHistoryViewController.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 15/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit
import Reusable
import EasyBelote_Core_iOS

final class RoundHistoryViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: Properties

    private var game: Game!
    private var tokens = [NSKeyValueObservation]()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        makeObservers()
    }

    deinit {
        tokens.invalidateAll()
    }

    func inject(game: Game) {
        self.game = game
    }

}

// MARK: - Observers

extension RoundHistoryViewController {

    private func configureTableView() {
        tableView.register(cellType: RoundTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }

}

// MARK: - Observers

extension RoundHistoryViewController {

    private func makeObservers() {
        observeRounds()
    }

    private func observeRounds() {
        let token = game.observe(\.rounds, options: [.initial, .new]) { [unowned self] _, _ in
            self.tableView.reloadData()
        }
        tokens.append(token)
    }

}

// MARK: - UITableViewDataSource

extension RoundHistoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        game.rounds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RoundTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(round: game.rounds[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

}

// MARK: - UITableViewDelegate

extension RoundHistoryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        DispatchQueue.main.async {
            let row = indexPath.row
            let roundNavController = StoryboardScene.Game.roundVC.instantiate()
            (roundNavController.topViewController as? RoundViewController)?.inject(game: self.game,
                                                                                   round: self.game.rounds[row])
            self.parent?.present(roundNavController, animated: true)
        }
    }

}
