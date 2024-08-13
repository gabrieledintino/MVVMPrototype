//
//  DriversListViewModelIntegrationTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 13/08/24.
//

import XCTest
import Cuckoo

final class DriversListViewModelIntegrationTests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var sut: DriversListViewModel!
    var spy: MockNetworkClientProtocol!

    override func setUp() {
        super.setUp()
        spy = MockNetworkClientProtocol()
        spy.enableDefaultImplementation(NetworkClient())
        sut = DriversListViewModel(networkClient: spy)
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testFetchDriversSuccess() async throws {
        // When
        await sut.fetchDrivers()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.drivers, drivers)
        verify(spy).fetchDrivers()
        verifyNoMoreInteractions(spy)
    }
    
    func testFilteredDrivers() async {
        // Given
        await sut.fetchDrivers()
        
        // When - No search text
        sut.searchText = ""
        
        // Then
        XCTAssertEqual(sut.filteredDrivers, drivers)
        
        // When - No search text
        sut.searchText = "al"
        var filteredDrivers = self.drivers.filter { $0.fullName.lowercased().contains("al") }
        // Then
        XCTAssertEqual(sut.filteredDrivers, filteredDrivers)
        
        // When - Search for "Ham"
        sut.searchText = "alb"
        filteredDrivers = self.drivers.filter { $0.fullName.lowercased().contains("alb") }
        // Then
        XCTAssertEqual(sut.filteredDrivers, filteredDrivers)
        
        // When - Search for "Max"
        sut.searchText = "alo"
        filteredDrivers = self.drivers.filter { $0.fullName.lowercased().contains("alo") }

        // Then
        XCTAssertEqual(sut.filteredDrivers, filteredDrivers)
        
        // When - Search for non-existent driver
        sut.searchText = "zzz"
        
        // Then
        XCTAssertTrue(sut.filteredDrivers.isEmpty)
        
        verify(spy).fetchDrivers()
        verifyNoMoreInteractions(spy)
    }
}
