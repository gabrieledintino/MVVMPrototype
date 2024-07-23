//
//  FavoriteDriversViewModelTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 19/07/24.
//

import XCTest
@testable import MVVMPrototype

class FavoriteDriversViewModelTests: XCTestCase {
    var viewModel: FavoriteDriversViewModel!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Use an in-memory UserDefaults for testing
        mockUserDefaults = UserDefaults(suiteName: #file)
        mockUserDefaults.removePersistentDomain(forName: #file)
        
        viewModel = FavoriteDriversViewModel(userDefaults: mockUserDefaults)
        // Inject the mock UserDefaults
        //viewModel.defaults = mockUserDefaults
    }
    
    override func tearDown() {
        viewModel = nil
        mockUserDefaults = nil
        super.tearDown()
    }
    
    func testLoadFavoriteDrivers() async {
        // Arrange
        let mockDriverIDs = ["driver1", "driver2"]
        mockUserDefaults.set(mockDriverIDs, forKey: "FavoriteDrivers")
        
        // Act
        await viewModel.loadFavoriteDrivers()
        
        // Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.favoriteDrivers.count, 2)
        XCTAssertEqual(viewModel.favoriteDrivers[0].driverID, "driver1")
        XCTAssertEqual(viewModel.favoriteDrivers[1].driverID, "driver2")
    }
    
    func testRemoveFavorite() {
        // Arrange
        let mockDriver = Driver(driverID: "driver1", permanentNumber: "1", code: "D1", url: "http://example.com", givenName: "John", familyName: "Doe", dateOfBirth: "1990-01-01", nationality: "American")
        viewModel.favoriteDrivers = [mockDriver]
        mockUserDefaults.set(["driver1"], forKey: "FavoriteDrivers")
        
        // Act
        viewModel.removeFavorite(mockDriver)
        
        // Assert
        XCTAssertTrue(viewModel.favoriteDrivers.isEmpty)
        XCTAssertNil(mockUserDefaults.array(forKey: "FavoriteDrivers"))
    }
    
    func testRemoveFavorites() {
        // Arrange
        let mockDrivers = [
            Driver(driverID: "driver1", permanentNumber: "1", code: "D1", url: "http://example.com", givenName: "John", familyName: "Doe", dateOfBirth: "1990-01-01", nationality: "American"),
            Driver(driverID: "driver2", permanentNumber: "2", code: "D2", url: "http://example.com", givenName: "Jane", familyName: "Doe", dateOfBirth: "1991-01-01", nationality: "British")
        ]
        viewModel.favoriteDrivers = mockDrivers
        mockUserDefaults.set(["driver1", "driver2"], forKey: "FavoriteDrivers")
        
        // Act
        viewModel.removeFavorites(at: IndexSet(integer: 0))
        
        // Assert
        XCTAssertEqual(viewModel.favoriteDrivers.count, 1)
        XCTAssertEqual(viewModel.favoriteDrivers[0].driverID, "driver2")
        XCTAssertEqual(mockUserDefaults.stringArray(forKey: "FavoriteDrivers"), ["driver2"])
    }
}
