//
//  Player.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import Foundation

struct Player: Identifiable, Hashable {
    let id: Int
    let name: String
    let team: String
}

struct PlayerStats {
    let player: Player
    let points: Double
    let assists: Double
    let rebounds: Double
}
