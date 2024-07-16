//
//  BallDontLiePlayer.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import Foundation

// MARK: - PlayerSearchResponse
struct PlayerSearchResponse: Codable {
    let data: [PlayerInfo]
    let meta: Meta
}

// MARK: - Datum
struct PlayerInfo: Codable, Hashable {
    let id: Int
    let firstName, lastName, position, height: String?
    let weight, jerseyNumber, college, country: String?
    let draftYear, draftRound, draftNumber: Int?
    let team: Team?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case position, height, weight
        case jerseyNumber = "jersey_number"
        case college, country
        case draftYear = "draft_year"
        case draftRound = "draft_round"
        case draftNumber = "draft_number"
        case team
    }
}

// MARK: - Team
struct Team: Codable, Hashable {
    let id: Int
    let conference, division, city, name: String
    let fullName, abbreviation: String

    enum CodingKeys: String, CodingKey {
        case id, conference, division, city, name
        case fullName = "full_name"
        case abbreviation
    }
}

// MARK: - Meta
struct Meta: Codable {
    let perPage: Int

    enum CodingKeys: String, CodingKey {
        case perPage = "per_page"
    }
}
