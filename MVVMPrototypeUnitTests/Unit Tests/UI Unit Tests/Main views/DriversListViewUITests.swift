//
//  TestUiTest.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 05/08/24.
//

import XCTest
import ViewInspector
@testable import MVVMPrototype
import SwiftUI
import Cuckoo

class DriversListViewUITests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var mockVM: MockDriversListViewModel!
    var originalVM: DriversListViewModel!
    var sut: DriversListView!
    
    override func setUp() {
        super.setUp()
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
        
        mockVM = MockDriversListViewModel()
        originalVM = DriversListViewModel()        
        mockVM.enableDefaultImplementation(originalVM)
        sut = DriversListView(viewModel: mockVM)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTaskMethodIsInvoked() throws {
        let exp = sut.inspection.inspect(after: 1.0) { view in
            verify(self.mockVM).fetchDrivers()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3.0)
    }
    
    func testProgressViewIsShownAndOthersHidden() throws {
        stub(mockVM) { stub in
            when(stub.isLoading.get).thenReturn(true)
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertTrue(try view.actualView().viewModel.isLoading)
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3.0)
    }
    
    func testErrorViewIsShownAndOthersHidden() throws {
        stub(mockVM) { stub in
            when(stub.errorMessage.get).thenReturn("Test error")
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "error_view").isHidden())
            XCTAssertEqual(try view.navigationView().zStack().view(ErrorView.self, 0).vStack().image(0).actualImage().name(), "exclamationmark.triangle")
            XCTAssertEqual(try view.navigationView().zStack().view(ErrorView.self, 0).vStack().text(1).string(), "Error")
            XCTAssertEqual(try view.navigationView().zStack().view(ErrorView.self, 0).vStack().text(2).string(), "Test error")
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3.0)
    }
    
    func testDriverListIsShownAndOthersHidden() throws {
        stub(mockVM) { stub in
            when(stub.drivers.get).thenReturn(self.drivers)
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3.0)
    }
    
    func testDriverRowIsRenderedCorrectly() throws {
        stub(mockVM) { stub in
            when(stub.filteredDrivers.get).thenReturn(self.drivers)
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(0).labelView().view(DriverRow.self).vStack().text(0).string(), "Alexander Albon")
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(0).labelView().view(DriverRow.self).vStack().text(1).string(), "Thai")
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(1).labelView().view(DriverRow.self).vStack().text(0).string(), "Fernando Alonso")
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(1).labelView().view(DriverRow.self).vStack().text(1).string(), "Spanish")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3.0)
    }
}
