//
//  FavoriteDriversViewModelTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 19/07/24.
//

import XCTest
@testable import MVVMPrototype
import Cuckoo

class FavoriteDriversViewModelTests: XCTestCase {
    var viewModel: FavoriteDriversViewModel!
    var mockUserDefaults: UserDefaults!
    var mockNetworkClient: MockNetworkClientProtocol!
    var testDrivers: [Driver]!
    
    override func setUp() {
        super.setUp()
        // Use an in-memory UserDefaults for testing
        mockUserDefaults = UserDefaults(suiteName: #file)
        mockUserDefaults.removePersistentDomain(forName: #file)
        
        mockNetworkClient = MockNetworkClientProtocol()
        let driverResponse: DriversListYearResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        testDrivers = driverResponse.mrData.driverTable.drivers
        
        viewModel = FavoriteDriversViewModel(networkClient: mockNetworkClient, userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        viewModel = nil
        mockUserDefaults.removePersistentDomain(forName: #file)
        mockUserDefaults = nil
        super.tearDown()
    }
    
    func testLoadFavoriteDrivers() async {
        // Given
        let mockDriverIDs = ["leclerc", "albon"]
        mockUserDefaults.set(mockDriverIDs, forKey: "FavoriteDrivers")
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.testDrivers
          }
        }
        
        // When
        await viewModel.loadFavoriteDrivers()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.favoriteDrivers.count, 2)
        XCTAssertEqual(viewModel.favoriteDrivers[0].driverID, "albon")
        XCTAssertEqual(viewModel.favoriteDrivers[1].driverID, "leclerc")
    }
    
    func testLoadFavoriteDriversThrowsError() async {
        // Given
        let mockDriverIDs = ["leclerc", "albon"]
        mockUserDefaults.set(mockDriverIDs, forKey: "FavoriteDrivers")
        
        let expectedError = NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        stub(mockNetworkClient) { stub in
            when(stub.fetchDrivers()).thenThrow(expectedError)
        }
        
        // When
        await viewModel.loadFavoriteDrivers()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, expectedError.localizedDescription)
        XCTAssertEqual(viewModel.favoriteDrivers.count, 0)
        verify(mockNetworkClient).fetchDrivers()
        verifyNoMoreInteractions(mockNetworkClient)
    }
    
    func testLoadFavoriteDriversWhenEmpty() async {
        // Given
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.testDrivers
          }
        }
        
        // When
        await viewModel.loadFavoriteDrivers()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.favoriteDrivers.count, 0)
        XCTAssertTrue(viewModel.favoriteDrivers.isEmpty)
        //XCTAssertEqual(viewModel.favoriteDrivers[0].driverID, "albon")
        //XCTAssertEqual(viewModel.favoriteDrivers[1].driverID, "leclerc")
    }
    
    func testRemoveFavorite() {
        // Given
        let mockDriver = Driver(driverID: "driver1", permanentNumber: "1", code: "D1", url: "http://example.com", givenName: "John", familyName: "Doe", dateOfBirth: "1990-01-01", nationality: "American")
        viewModel.favoriteDrivers = [mockDriver]
        mockUserDefaults.set(["driver1"], forKey: "FavoriteDrivers")
        
        // When
        viewModel.removeFavorite(mockDriver)
        
        // Then
        XCTAssertTrue(viewModel.favoriteDrivers.isEmpty)
        XCTAssertTrue(mockUserDefaults.array(forKey: "FavoriteDrivers")!.isEmpty)

        XCTAssertEqual(mockUserDefaults.array(forKey: "FavoriteDrivers")!.count, 0)
    }
    
    func testRemoveFavoriteWhenEmpty() {
        // Given
        let mockDriver = Driver(driverID: "driver1", permanentNumber: "1", code: "D1", url: "http://example.com", givenName: "John", familyName: "Doe", dateOfBirth: "1990-01-01", nationality: "American")
        
        // When
        viewModel.removeFavorite(mockDriver)
        
        // Then
        XCTAssertTrue(viewModel.favoriteDrivers.isEmpty)
        XCTAssertTrue(mockUserDefaults.array(forKey: "FavoriteDrivers")!.isEmpty)

        XCTAssertEqual(mockUserDefaults.array(forKey: "FavoriteDrivers")!.count, 0)
    }
    
    func testRemoveFavorites() {
        // Given
        let mockDrivers = [
            Driver(driverID: "driver1", permanentNumber: "1", code: "D1", url: "http://example.com", givenName: "John", familyName: "Doe", dateOfBirth: "1990-01-01", nationality: "American"),
            Driver(driverID: "driver2", permanentNumber: "2", code: "D2", url: "http://example.com", givenName: "Jane", familyName: "Doe", dateOfBirth: "1991-01-01", nationality: "British")
        ]
        viewModel.favoriteDrivers = mockDrivers
        mockUserDefaults.set(["driver1", "driver2"], forKey: "FavoriteDrivers")
        
        // When
        viewModel.removeFavorites(at: IndexSet(integer: 0))
        
        // Then
        XCTAssertEqual(viewModel.favoriteDrivers.count, 1)
        XCTAssertEqual(viewModel.favoriteDrivers[0].driverID, "driver2")
        XCTAssertEqual(mockUserDefaults.stringArray(forKey: "FavoriteDrivers"), ["driver2"])
    }
}
