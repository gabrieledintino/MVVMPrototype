//
//  FavoriteDriversViewModelIntegrationTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 13/08/24.
//

import XCTest
import Cuckoo

final class FavoriteDriversViewModelIntegrationTests: XCTestCase {
    var viewModel: FavoriteDriversViewModel!
    var standardUserDefaults: UserDefaults!
    var testDrivers: [Driver]!
    var spy: MockNetworkClientProtocol!

    override func setUp() {
        super.setUp()
        standardUserDefaults = UserDefaults.standard
        standardUserDefaults.removeObject(forKey: "FavoriteDrivers")
        spy = MockNetworkClientProtocol()
        spy.enableDefaultImplementation(NetworkClient())
        
        let driverResponse: DriversListYearResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        testDrivers = driverResponse.mrData.driverTable.drivers
        
        viewModel = FavoriteDriversViewModel(networkClient: spy, userDefaults: standardUserDefaults)
    }
    
    override func tearDown() {
        viewModel = nil
        standardUserDefaults.removeObject(forKey: "FavoriteDrivers")
        super.tearDown()
    }
    
    func testLoadFavoriteDrivers() async {
        // Given
        let mockDriverIDs = ["leclerc", "albon"]
        standardUserDefaults.set(mockDriverIDs, forKey: "FavoriteDrivers")
        
        // When
        await viewModel.loadFavoriteDrivers()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.favoriteDrivers.count, 2)
        XCTAssertEqual(viewModel.favoriteDrivers[0].driverID, "albon")
        XCTAssertEqual(viewModel.favoriteDrivers[1].driverID, "leclerc")
        verify(spy).fetchDrivers()
        verifyNoMoreInteractions(spy)
    }
    
    func testLoadFavoriteDriversWhenEmpty() async {
        // When
        await viewModel.loadFavoriteDrivers()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.favoriteDrivers.count, 0)
        XCTAssertTrue(viewModel.favoriteDrivers.isEmpty)
        verify(spy).fetchDrivers()
        verifyNoMoreInteractions(spy)
    }
    
    func testRemoveFavorite() {
        // Given
        let mockDriver = Driver(driverID: "driver1", permanentNumber: "1", code: "D1", url: "http://example.com", givenName: "John", familyName: "Doe", dateOfBirth: "1990-01-01", nationality: "American")
        viewModel.favoriteDrivers = [mockDriver]
        standardUserDefaults.set(["driver1"], forKey: "FavoriteDrivers")
        
        // When
        viewModel.removeFavorite(mockDriver)
        
        // Then
        XCTAssertTrue(viewModel.favoriteDrivers.isEmpty)
        XCTAssertTrue(standardUserDefaults.array(forKey: "FavoriteDrivers")!.isEmpty)

        XCTAssertEqual(standardUserDefaults.array(forKey: "FavoriteDrivers")!.count, 0)
    }
    
    func testRemoveFavoriteWhenEmpty() {
        // Given
        let mockDriver = Driver(driverID: "driver1", permanentNumber: "1", code: "D1", url: "http://example.com", givenName: "John", familyName: "Doe", dateOfBirth: "1990-01-01", nationality: "American")
        
        // When
        viewModel.removeFavorite(mockDriver)
        
        // Then
        XCTAssertTrue(viewModel.favoriteDrivers.isEmpty)
        XCTAssertTrue(standardUserDefaults.array(forKey: "FavoriteDrivers")!.isEmpty)

        XCTAssertEqual(standardUserDefaults.array(forKey: "FavoriteDrivers")!.count, 0)
    }
    
    func testRemoveFavorites() {
        // Given
        let mockDrivers = [
            Driver(driverID: "driver1", permanentNumber: "1", code: "D1", url: "http://example.com", givenName: "John", familyName: "Doe", dateOfBirth: "1990-01-01", nationality: "American"),
            Driver(driverID: "driver2", permanentNumber: "2", code: "D2", url: "http://example.com", givenName: "Jane", familyName: "Doe", dateOfBirth: "1991-01-01", nationality: "British")
        ]
        viewModel.favoriteDrivers = mockDrivers
        standardUserDefaults.set(["driver1", "driver2"], forKey: "FavoriteDrivers")
        
        // When
        viewModel.removeFavorites(at: IndexSet(integer: 0))
        
        // Then
        XCTAssertEqual(viewModel.favoriteDrivers.count, 1)
        XCTAssertEqual(viewModel.favoriteDrivers[0].driverID, "driver2")
        XCTAssertEqual(standardUserDefaults.stringArray(forKey: "FavoriteDrivers"), ["driver2"])
    }

}
