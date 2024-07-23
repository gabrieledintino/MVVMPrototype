//
//  DriversViewModelTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 22/07/24.
//

import XCTest
@testable import MVVMPrototype

final class DriversViewModelTests: XCTestCase {
    var drivers: [Driver]!
    
    var viewModel: DriversViewModel!
    //var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        viewModel = DriversViewModel()
        //let decodedData: DriversListYearResponse = Bundle.main.decode("drivers.json")
        //drivers = decodedData.mrData.driverTable.drivers
        
//        let bundle = Bundle(for: type(of: self))
//        let path = bundle.url(forResource: "drivers", withExtension: "json")!
//        let jsonData = try! Data(contentsOf: path)
//        let decoder = JSONDecoder()
//        let response: DriversListYearResponse = try! decoder.decode(DriversListYearResponse.self, from: jsonData)
        let response: DriversListYearResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = response.mrData.driverTable.drivers
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testDrivers() throws {
        XCTAssertEqual(drivers.count, 21)
    }

}
