//
//  FavorireDriversViewUITests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 10/08/24.
//

import XCTest
import ViewInspector
@testable import MVVMPrototype
import SwiftUI
import Cuckoo

final class FavoriteDriversViewUITests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var mockVM: MockFavoriteDriversViewModel!
    var originalVM: FavoriteDriversViewModel!
    var sut: FavoriteDriversView!
    
    override func setUp() {
        super.setUp()
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
        
        mockVM = MockFavoriteDriversViewModel()
        originalVM = FavoriteDriversViewModel()
        mockVM.enableDefaultImplementation(originalVM)
        sut = FavoriteDriversView(viewModel: mockVM)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
//    func testTaskMethodIsInvoked() throws {
//        let exp = sut.inspection.inspect(after: 1.0) { view in
//            verify(self.mockVM).fetchDrivers()
//        }
//        ViewHosting.host(view: sut)
//        wait(for: [exp], timeout: 2.0)
//    }
    
    func testProgressViewIsShownAndOthersHidden() throws {
        stub(mockVM) { stub in
            when(stub.isLoading.get).thenReturn(true)
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertTrue(try view.actualView().viewModel.isLoading)
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "text_view"))
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
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "text_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))

        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3.0)
    }
    
    func testDriverListIsEmptyShowsText() throws {
        stub(mockVM) { stub in
            when(stub.favoriteDrivers.get).thenReturn([])
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "text_view").isHidden())
            XCTAssertEqual(try view.navigationView().zStack().text(0).string(), "No favorite drivers yet")
            XCTAssertEqual(try view.navigationView().zStack().text(0).attributes().foregroundColor(), .secondary)
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3.0)
    }
    
    func testDriverListIsShownAndOthersHidden() throws {
        stub(mockVM) { stub in
            when(stub.favoriteDrivers.get).thenReturn([self.drivers[0], self.drivers[1], self.drivers[2]])
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "text_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).count, 3)
            XCTAssertThrowsError(try view.navigationView().zStack().list(0).forEach(0).navigationLink(4))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3.0)
    }
    
    func testDriverRowIsRenderedCorrectly() throws {
        stub(mockVM) { stub in
            when(stub.favoriteDrivers.get).thenReturn([self.drivers[0]])
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(0).labelView().view(DriverRow.self).vStack().text(0).string(), "Alexander Albon")
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(0).labelView().view(DriverRow.self).vStack().text(1).string(), "Thai")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3.0)
    }
}
