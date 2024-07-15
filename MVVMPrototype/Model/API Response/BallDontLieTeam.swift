//
//  BallDontLieTeam.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import Foundation

struct BallDontLieTeam: Codable {
    let id: Int
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
    }
}
