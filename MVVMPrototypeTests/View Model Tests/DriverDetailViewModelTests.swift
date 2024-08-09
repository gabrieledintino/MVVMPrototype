//
//  DriverDetailViewModelTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 01/08/24.
//

import XCTest
@testable import MVVMPrototype
import Cuckoo

final class DriverDetailViewModelTests: XCTestCase {
    var mockNetworkClient: MockNetworkClientProtocol!
    var sut: DriverDetailViewModel!
    var testDriver: Driver!
    var raceResults: [Race]!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        mockNetworkClient = MockNetworkClientProtocol()
        // Use an in-memory UserDefaults for testing
        mockUserDefaults = UserDefaults(suiteName: #file)
        mockUserDefaults.removePersistentDomain(forName: #file)
        
        let driverResponse: DriversListYearResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        testDriver = driverResponse.mrData.driverTable.drivers.first(where: { $0.driverID == "leclerc" })
        let resultsResponse: RaceResultResponse = try! FileUtils.loadJSONData(from: "leclerc_results", withExtension: "json", in: type(of: self))
        raceResults = resultsResponse.mrData.raceTable.races
        
        sut = DriverDetailViewModel(driver: testDriver, networkClient: mockNetworkClient, userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkClient = nil
        super.tearDown()
    }
    
    func testFetchRaceResultsSuccess() async throws {
        // Given
        stub(mockNetworkClient) { stub in
            when(stub.fetchRaceResults(forDriver: "leclerc")).thenReturn(self.raceResults)
        }
        
        // When
        await sut.fetchRaceResults()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.races, raceResults)
        verify(mockNetworkClient).fetchRaceResults(forDriver: "leclerc")
        verifyNoMoreInteractions(mockNetworkClient)
    }
    
    func testFetchRaceResultsFailure() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        
        stub(mockNetworkClient) { stub in
            when(stub.fetchRaceResults(forDriver: "leclerc")).thenThrow(expectedError)
        }
        
        // When
        await sut.fetchRaceResults()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.errorMessage, expectedError.localizedDescription)
        XCTAssertTrue(sut.races.isEmpty)
        verify(mockNetworkClient).fetchRaceResults(forDriver: "leclerc")
        verifyNoMoreInteractions(mockNetworkClient)
    }
    
    func testToggleFavorite() {
        // Given
        XCTAssertFalse(sut.isFavorite)
        
        // When
        sut.toggleFavorite()
        
        // Then
        XCTAssertTrue(sut.isFavorite)
        
        // When
        sut.toggleFavorite()
        
        // Then
        XCTAssertFalse(sut.isFavorite)
    }
    
    func testFormattedDateOfBirthSuccess() {
        // Given
        let expectedDate = "16 Oct 1997" // This assumes the current locale is set to it_IT
        
        // When
        let formattedDate = sut.formattedDateOfBirth
        
        // Then
        XCTAssertEqual(formattedDate, expectedDate)
    }
    
    func testFormattedDateOfBirthFailure() {
        // Given
        testDriver = Driver(driverID: "driver1", permanentNumber: "1", code: "D1", url: "http://example.com", givenName: "John", familyName: "Doe", dateOfBirth: "XXX", nationality: "American")
        sut = DriverDetailViewModel(driver: testDriver, networkClient: mockNetworkClient)
        
        // When
        let formattedDate = sut.formattedDateOfBirth
        
        // Then
        XCTAssertNil(formattedDate)
    }
}
