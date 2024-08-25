//
//  CuckooMockTest.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 31/07/24.
//

import XCTest
@testable import MVVMPrototype
import Cuckoo


final class DriversListViewModelTests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var mockNetworkClient: MockNetworkClientProtocol!
    var sut: DriversListViewModel!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClientProtocol()
        sut = DriversListViewModel(networkClient: mockNetworkClient)
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkClient = nil
        super.tearDown()
    }
    
    func testFetchDriversSuccess() async throws {
        // Given
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        
        // When
        await sut.fetchDrivers()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.drivers, drivers)
        verify(mockNetworkClient).fetchDrivers()
        verifyNoMoreInteractions(mockNetworkClient)
    }
    
    func testFetchDriversFailure() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              throw expectedError
          }
        }
        // When
        await sut.fetchDrivers()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.errorMessage, expectedError.localizedDescription)
        XCTAssertTrue(sut.drivers.isEmpty)
        verify(mockNetworkClient).fetchDrivers()
        verifyNoMoreInteractions(mockNetworkClient)
    }
    
    func testFilteredDrivers() {
        // Given
        let driver1 = drivers[0]
        let driver2 = drivers[1]
        sut.drivers = [driver1, driver2]
        
        // When - No search text
        sut.searchText = ""
        
        // Then
        XCTAssertEqual(sut.filteredDrivers, [driver1, driver2])
        
        // When - No search text
        sut.searchText = "al"
        
        // Then
        XCTAssertEqual(sut.filteredDrivers, [driver1, driver2])
        
        sut.searchText = "alb"
        
        // Then
        XCTAssertEqual(sut.filteredDrivers, [driver1])
        
        sut.searchText = "alo"
        
        // Then
        XCTAssertEqual(sut.filteredDrivers, [driver2])
        
        // When - Search for non-existent driver
        sut.searchText = "zzz"
        
        // Then
        XCTAssertTrue(sut.filteredDrivers.isEmpty)
    }
}
