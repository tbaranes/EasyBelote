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

    var pointsHanging = 0
    private(set) var nextRoundPointsHanging = 0

    // MARK: Life cycle

    init(teams: [TeamRound], pointsHanging: Int) {
        self.teams = teams
        self.pointsHanging = pointsHanging
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
        if checkInside {
            makeFinalScore()
        }
    }

    func makeFinalScore() {
        guard teams.allSatisfy({ $0.score >= 0 }), !hasCapot, nextRoundPointsHanging == 0 else {
            return
        }

        let teamNoBidder = teams.first { !$0.isBidder }
        guard let teamBidder = teams.first(where: { $0.isBidder }), teamBidder.score < Belote.biddingSuccess else {
            return
        }

        if teamBidder.score == teamNoBidder?.score {
            nextRoundPointsHanging = teamBidder.score
            teamBidder.score = 0
        } else {
            teamBidder.score = 0
            if teamNoBidder?.score != Belote.capotPoints {
                teamNoBidder?.score = Belote.roundPoints
            }
        }
    }

    private var hasCapot: Bool {
        return !teams.allSatisfy { $0.declarations.contains(.capot) == false }
    }

}

// MARK: - Final Score

extension Round {

    public var teamsScore: (Int, Int) {
        guard let team1 = teams.first, let team2 = teams.last else {
            return (0, 0)
        }

        let teamWinningHangingPoints = findTeamWinningHangingPoints(team1: team1, team2: team2)
        var team1Score = team1.score + (team1 == teamWinningHangingPoints ? pointsHanging : 0)
        var team2Score = team2.score + (team2 == teamWinningHangingPoints ? pointsHanging : 0)
        team1Score += team1.declarations.reduce(0) { $0 + $1.pointsValue }
        team2Score += team2.declarations.reduce(0) { $0 + $1.pointsValue }
        return (team1Score, team2Score)
    }

    private func findTeamWinningHangingPoints(team1: TeamRound, team2: TeamRound) -> TeamRound {
        let teamResult: [(team: TeamRound, score: Int, isBidder: Bool)] = [(team1, team1.score, team1.isBidder),
                                                                           (team2, team2.score, team2.isBidder)]
        var teamWinningHangingPoints = teamResult.first { $0.isBidder && $0.score > 81 }?.team
        if teamWinningHangingPoints == nil {
            teamWinningHangingPoints = teamResult.first { !$0.isBidder }?.team
        }
        return teamWinningHangingPoints!
    }

}
