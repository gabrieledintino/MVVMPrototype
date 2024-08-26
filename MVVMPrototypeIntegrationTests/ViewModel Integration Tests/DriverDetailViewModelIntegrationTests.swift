//
//  DriverDetailViewModelIntegrationTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 13/08/24.
//

import XCTest
import Cuckoo

final class DriverDetailViewModelIntegrationTests: XCTestCase {
    var sut: DriverDetailViewModel!
    var testDriver: Driver!
    var raceResults: [Race]!
    var standardUserDefaults: UserDefaults!
    var spy: MockNetworkClientProtocol!
    
    override func setUp() {
        super.setUp()
        standardUserDefaults = UserDefaults.standard
        standardUserDefaults.removeObject(forKey: "FavoriteDrivers")
        spy = MockNetworkClientProtocol()
        spy.enableDefaultImplementation(NetworkClient())
        let driverResponse: DriversListYearResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        testDriver = driverResponse.mrData.driverTable.drivers.first(where: { $0.driverID == "leclerc" })
        let resultsResponse: RaceResultResponse = try! FileUtils.loadJSONData(from: "leclerc_results", withExtension: "json", in: type(of: self))
        raceResults = resultsResponse.mrData.raceTable.races
        
        sut = DriverDetailViewModel(driver: testDriver, networkClient: spy, userDefaults: standardUserDefaults)
    }
    
    override func tearDown() {
        sut = nil
        standardUserDefaults.removeObject(forKey: "FavoriteDrivers")
        super.tearDown()
    }
    
    func testFetchRaceResultsSuccess() async throws {
        // When
        await sut.fetchRaceResults()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(sut.races.count > 0)
        verify(spy).fetchRaceResults(forDriver: "leclerc")
        verifyNoMoreInteractions(spy)
    }
}
