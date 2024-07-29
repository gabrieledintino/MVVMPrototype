//
//  MockNetworkClient.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 29/07/24.
//

import XCTest
@testable import MVVMPrototype

// MARK: - Mock Network Client
class MockNetworkClient: NetworkClientProtocol {
    var mockDrivers: [Driver]?
    var mockResults: [Race]?
    var mockError: Error?
    
    func fetchDrivers() async throws -> [Driver] {
        if let error = mockError {
            throw error
        }
        return mockDrivers ?? []
    }
    
    func fetchRaceResults(forDriver driverId: String) async throws -> [Race] {
        if let error = mockError {
            throw error
        }
        return mockResults ?? []
    }
}
