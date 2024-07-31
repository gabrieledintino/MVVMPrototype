//
//  Mocktest.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 29/07/24.
//

import XCTest
import Mockingbird
@testable import MVVMPrototype

final class DriversListViewModelTests2: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    
    var test: NetworkClientProtocol!
    
    var sut: DriversListViewModel!
    var mockNetworkClient: NetworkClientProtocolMock!
    
    
    override func setUp() {
        super.setUp()
        test = mock(NetworkClientProtocol.self)
        
        mockNetworkClient = mock(NetworkClientProtocol.self)
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
        //given(await mockNetworkClient.fetchDrivers()).willReturn(drivers)
        
        // When
        await sut.fetchDrivers()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.drivers, drivers)
        verify(await mockNetworkClient.fetchDrivers()).wasCalled()
    }
    
    func testFetchDriversFailure() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        givenSwift(await mockNetworkClient.fetchDrivers()).will { throw expectedError }
        
        // When
        await sut.fetchDrivers()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.errorMessage, expectedError.localizedDescription)
        XCTAssertTrue(sut.drivers.isEmpty)
        verify(await mockNetworkClient.fetchDrivers()).wasCalled()
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
        
        // When - Search for "Ham"
        sut.searchText = "alb"
        
        // Then
        XCTAssertEqual(sut.filteredDrivers, [driver1])
        
        // When - Search for "Max"
        sut.searchText = "alo"
        
        // Then
        XCTAssertEqual(sut.filteredDrivers, [driver2])
        
        // When - Search for non-existent driver
        sut.searchText = "zzz"
        
        // Then
        XCTAssertTrue(sut.filteredDrivers.isEmpty)
    }
    
}
