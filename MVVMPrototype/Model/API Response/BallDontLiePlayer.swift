//
//  BallDontLiePlayer.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import Foundation

struct BallDontLiePlayer: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let team: BallDontLieTeam
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case team
    }
}
