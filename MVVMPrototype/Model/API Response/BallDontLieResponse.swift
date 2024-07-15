//
//  BallDontLieResponse.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import Foundation

struct BallDontLieResponse<T: Codable>: Codable {
    let data: [T]
}
