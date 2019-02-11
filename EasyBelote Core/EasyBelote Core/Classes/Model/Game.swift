//
//  Game.swift
//  EasyBelote Core iOS
//
//  Created by Tom Baranes on 11/02/2019.
//  Copyright © 2019 sample. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

public enum GameState: Int {
    case configuring, playing
}

public final class Game: NSObject {

    // MARK: Properties

    @objc dynamic public var gameState: Int = GameState.configuring.rawValue

    public var teams: [[Player]]
    public var nbPoints: Int
    public var isDeclarationsEnabled: Bool

    @objc dynamic public var rounds = [Round]()
    @objc dynamic public var currentDealerId: Int

    // MARK: Life Cycle

    public override init() {
        let userDefaults = UserDefaults.standard
        if let players = userDefaults[.players] {
            teams = [players.filter { $0.id == 0 || $0.id == 2 }, players.filter { $0.id == 1 || $0.id == 3 }]
        } else {
            teams = [[Player(id: 0), Player(id: 2)], [Player(id: 1), Player(id: 3)]]
        }
        nbPoints = userDefaults[.nbPoints] > 0 ? userDefaults[.nbPoints] : 1001
        isDeclarationsEnabled = userDefaults[.isDeclarationsEnabled]

        rounds = []
        currentDealerId = 0
        super.init()
    }

    public func startGame() {
        let userDefaults = UserDefaults.standard
        userDefaults[.players] = allPlayers
        userDefaults[.nbPoints] = nbPoints
        userDefaults[.isDeclarationsEnabled] = isDeclarationsEnabled

        gameState = GameState.playing.rawValue
    }

}

// MARK: - Game Helpers

extension Game {

    public var allPlayers: [Player] {
        return teams.reduce([]) { $0 + $1 }.sorted { $0.id < $1.id }
    }

    public var canStartGame: Bool {
        return allPlayers.allSatisfy { !$0.name.isEmpty }
    }

    public var availableDeclarations: [Declaration] {
        if isDeclarationsEnabled {
            return Declaration.allCases
        }
        return Declaration.permanentDeclarations.compactMap { Declaration(rawValue: $0) }
    }

    public func makeNewRound(bidderId: Int) -> Round {
        return Round(teams: [TeamRound(id: 0, isBidder: bidderId % 2 == 0),
                             TeamRound(id: 1, isBidder: bidderId % 2 == 1)],
                     pointsHanging: rounds.last?.nextRoundPointsHanging ?? 0)
    }

}

// MARK: - Game running

extension Game {

    public func moveToNextDealer() {
        currentDealerId = (currentDealerId - 1 < 0 ? teams.count * 2 : currentDealerId) - 1
    }

    public func updateRound(_ round: Round) {
        guard let roundIdx = rounds.index(where: { $0 == round })  else {
            return
        }

        round.makeFinalScore()
        rounds.replaceSubrange(roundIdx...roundIdx, with: [round])
        if rounds.count > roundIdx + 1 {
            rounds[roundIdx + 1].pointsHanging = round.nextRoundPointsHanging
        }
    }

    public func validateRound(_ round: Round) {
        round.makeFinalScore()
        rounds.append(round)
        moveToNextDealer()
    }

}

// MARK: - DefaultsKeys

public extension DefaultsKeys {
    static let players = DefaultsKey<[Player]?>("teams")
    static let nbPoints = DefaultsKey<Int>("nb_points")
    static let isDeclarationsEnabled = DefaultsKey<Bool>("is_declarations_enabled")
}
