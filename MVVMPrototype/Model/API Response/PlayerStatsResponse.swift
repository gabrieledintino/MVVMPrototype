//
//  BallDontLiePlayerStats.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import Foundation

// MARK: - PlayerStatsResponse
struct PlayerStatsResponse: Codable {
    let data: [PlayerStats]
}

// MARK: - Datum
struct PlayerStats: Codable {
    let pts, ast, turnover, pf: Double
    let fga, fgm, fta, ftm: Double
    let fg3A, fg3M, reb, oreb: Double
    let dreb: Int
    let stl, blk, fgPct, fg3Pct: Double
    let ftPct: Double
    let min: String
    let gamesPlayed, playerID, season: Int

    enum CodingKeys: String, CodingKey {
        case pts, ast, turnover, pf, fga, fgm, fta, ftm
        case fg3A = "fg3a"
        case fg3M = "fg3m"
        case reb, oreb, dreb, stl, blk
        case fgPct = "fg_pct"
        case fg3Pct = "fg3_pct"
        case ftPct = "ft_pct"
        case min
        case gamesPlayed = "games_played"
        case playerID = "player_id"
        case season
    }
}
