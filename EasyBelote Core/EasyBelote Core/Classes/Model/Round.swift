//
//  Round.swift
//  EasyBelote Core iOS
//
//  Created by Tom Baranes on 11/02/2019.
//  Copyright © 2019 sample. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

final public class Round: NSObject {

    // MARK: Properties

    public let teams: [TeamRound]
    public let isPlayingCoinche: Bool
    public var contract: RoundContract

    var pointsHanging = 0
    private(set) var nextRoundPointsHanging = 0

    // MARK: Life cycle

    init(teams: [TeamRound], isPlayingCoinche: Bool, pointsHanging: Int) {
        self.teams = teams
        self.isPlayingCoinche = isPlayingCoinche
        self.pointsHanging = pointsHanging
        self.contract = RoundContract(isPlayingCoinche: isPlayingCoinche)
    }

    public func changeBidderId(_ bidderId: Int) {
        guard teams.first(where: { $0.isBidder })?.id != bidderId else {
            return
        }

        teams.forEach {
            $0.score = -1
            $0.isBidder = $0.id == bidderId
            $0.declarationsObservable.removeAll()
        }
    }

}

// MARK: - Declarations

extension Round {

    public func toggleDeclaration(_ declaration: Declaration, to teamId: Int) {
        guard let teamDeclaring = teams.first(where: { $0.id == teamId }),
              let teamNoDeclaring = teams.first(where: { $0.id != teamId }) else {
                return
        }

        toggleDeclaration(declaration, teamDeclaring: teamDeclaring, teamNoDeclaring: teamNoDeclaring)
        if declaration == .capot {
            toggleCapot(teamDeclaring: teamDeclaring, teamNoDeclaring: teamNoDeclaring)
        }
    }

    private func toggleCapot(teamDeclaring: TeamRound, teamNoDeclaring: TeamRound) {
        let teamDeclaringHasCapot = teamDeclaring.declarations.contains(.capot)
        teamDeclaring.score = teamDeclaringHasCapot ? Belote.capotPoints : -1
        teamNoDeclaring.score = teamDeclaringHasCapot ? 0 : -1
    }

    private func toggleDeclaration(_ declaration: Declaration, teamDeclaring: TeamRound, teamNoDeclaring: TeamRound) {
        if !teamDeclaring.declarations.contains(declaration) {
            teamDeclaring.declarationsObservable.append(declaration.rawValue)
        } else {
            teamDeclaring.declarationsObservable.removeAll { $0 == declaration.rawValue }
        }

        if Declaration.permanentDeclarations.contains(declaration.rawValue) {
            teamNoDeclaring.declarationsObservable.removeAll { $0 == declaration.rawValue }
        } else if (teamDeclaring.declarations.max(by: { $0.pointsValue < $1.pointsValue })?.pointsValue ?? -1) >
                  (teamNoDeclaring.declarations.max(by: { $0.pointsValue < $1.pointsValue })?.pointsValue ?? -1) {
                    teamNoDeclaring.declarationsObservable.removeAll { !Declaration.permanentDeclarations.contains($0) }
        }
    }

    func cancelCapot() {
        teams.forEach {
            $0.declarationsObservable.removeAll { $0 == Declaration.capot.rawValue }
        }
    }

}

// MARK: - Scoring

extension Round {

    public func makeScore(team1Score: Int?, team2Score: Int?, checkInside: Bool) {
        guard (team1Score == nil && team2Score == nil) ||
              (team1Score != nil && teams.first?.score != team1Score) ||
              (team2Score != nil && teams.last?.score != team2Score) else {
                makeFinalScore(checkInside: checkInside)
                return
        }

        nextRoundPointsHanging = 0
        if let score = team1Score {
            teams.first?.score = score
            teams.last?.score = Belote.roundPoints - score
        } else if let score = team2Score {
            teams.last?.score = score
            teams.first?.score = Belote.roundPoints - score
        } else {
            teams.first?.score = -1
            teams.last?.score = -1
        }

        cancelCapot()
        makeFinalScore(checkInside: checkInside)
    }

    private func makeFinalScore(checkInside: Bool) {
        if checkInside {
            makeFinalScore()
        }
    }

    func makeFinalScore() {
        guard teams.allSatisfy({ $0.score >= 0 }), !hasCapot, nextRoundPointsHanging == 0 else {
            return
        }

        guard let teamBidder = teams.first(where: { $0.isBidder }),
              let teamNoBidder = teams.first(where: { !$0.isBidder }) else {
            return
        }

        let bidderBelote = beloteRebelotePoints(for: teamBidder)

        if isPlayingCoinche {
            // In coinche, bidder's belote counts toward meeting the contract
            guard (teamBidder.score + bidderBelote) < contract.points else {
                return
            }

            if teamBidder.score == teamNoBidder.score {
                nextRoundPointsHanging = teamBidder.score
                teamBidder.score = 0
            } else {
                teamBidder.score = 0
                if teamNoBidder.score != Belote.capotPoints {
                    teamNoBidder.score = Belote.roundPoints
                }
            }
        } else {
            // In classic, compare effective scores including belote/rebelote
            let defenderBelote = beloteRebelotePoints(for: teamNoBidder)
            let bidderTotal = teamBidder.score + bidderBelote
            let defenderTotal = teamNoBidder.score + defenderBelote

            if bidderTotal > defenderTotal {
                return // Contract met
            }

            if bidderTotal == defenderTotal {
                nextRoundPointsHanging = teamBidder.score
                teamBidder.score = 0
            } else {
                teamBidder.score = 0
                if teamNoBidder.score != Belote.capotPoints {
                    teamNoBidder.score = Belote.roundPoints
                }
            }
        }
    }

    private var hasCapot: Bool {
        return !teams.allSatisfy { $0.declarations.contains(.capot) == false }
    }

    private func beloteRebelotePoints(for team: TeamRound?) -> Int {
        return team?.declarations.contains(.belote) == true ? Declaration.belote.pointsValue : 0
    }

}

// MARK: - Final Score

extension Round {

    public var teamsScore: (Int, Int) {
        guard let team1 = teams.first, let team2 = teams.last else {
            return (0, 0)
        }

        let teamWinning = findTeamWinning(team1: team1, team2: team2)
        var team1Score = team1.score + (team1 == teamWinning ? pointsHanging : 0)
        var team2Score = team2.score + (team2 == teamWinning ? pointsHanging : 0)
        team1Score += team1.declarations.reduce(0) { $0 + $1.pointsValue }
        team2Score += team2.declarations.reduce(0) { $0 + $1.pointsValue }

        if isPlayingCoinche {
            // Defender's belote is a bonus (not multiplied), so remove it before multiplication
            let teamDefender = teams.first { !$0.isBidder }
            let defenderBelote = beloteRebelotePoints(for: teamDefender)
            if team1 == teamDefender {
                team1Score -= defenderBelote
            } else {
                team2Score -= defenderBelote
            }

            team1Score += teamWinning == team1 ? contract.points : 0
            team2Score += teamWinning == team2 ? contract.points : 0

            team1Score *= teamWinning == team1 ? contract.scoreMultiplier : 1
            team2Score *= teamWinning == team2 ? contract.scoreMultiplier : 1

            // Add back defender's belote as flat bonus
            if team1 == teamDefender {
                team1Score += defenderBelote
            } else {
                team2Score += defenderBelote
            }
        }

        return (team1Score, team2Score)
    }

    private func findTeamWinning(team1: TeamRound, team2: TeamRound) -> TeamRound {
        let teamBidder = team1.isBidder ? team1 : team2
        let teamDefender = team1.isBidder ? team2 : team1
        let bidderBelote = beloteRebelotePoints(for: teamBidder)

        let bidderWins: Bool
        if isPlayingCoinche {
            bidderWins = (teamBidder.score + bidderBelote) >= contract.points
        } else {
            let defenderBelote = beloteRebelotePoints(for: teamDefender)
            bidderWins = (teamBidder.score + bidderBelote) > (teamDefender.score + defenderBelote)
        }

        return bidderWins ? teamBidder : teamDefender
    }

}
