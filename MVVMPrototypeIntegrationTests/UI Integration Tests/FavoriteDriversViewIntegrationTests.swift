//
//  FavoriteDriversViewIntegrationTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 12/08/24.
//

import XCTest
import ViewInspector
@testable import MVVMPrototype
import SwiftUI

final class FavoriteDriversViewIntegrationTests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    
    override func setUp() {
        super.setUp()
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInitialState() throws {
        let sut = FavoriteDriversView()
        let exp = sut.inspection.inspect() { view in
            XCTAssertFalse(try view.actualView().viewModel.isLoading)
            XCTAssertFalse(try view.actualView().viewModel.errorMessage != nil)
            XCTAssertEqual(try view.actualView().viewModel.favoriteDrivers, [])
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 5.0)
    }
    
    func testProgressViewIsShownAndOthersHidden() throws {
        let sut = FavoriteDriversView()
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.isLoading = true
            XCTAssertTrue(try view.actualView().viewModel.isLoading)
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "text_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 5.0)
    }
    
    func testErrorViewIsShownAndOthersHidden() throws {
        let sut = FavoriteDriversView()
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.errorMessage = "Test error"
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "error_view").isHidden())
            XCTAssertEqual(try view.navigationView().zStack().view(ErrorView.self, 0).vStack().image(0).actualImage().name(), "exclamationmark.triangle")
            XCTAssertEqual(try view.navigationView().zStack().view(ErrorView.self, 0).vStack().text(1).string(), "Error")
            XCTAssertEqual(try view.navigationView().zStack().view(ErrorView.self, 0).vStack().text(2).string(), "Test error")
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "text_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))

        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 5.0)
    }
    
    func testDriverListIsEmptyShowsText() throws {
        let sut = FavoriteDriversView()
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.favoriteDrivers = []
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "text_view").isHidden())
            XCTAssertEqual(try view.navigationView().zStack().text(0).string(), "No favorite drivers yet")
            XCTAssertEqual(try view.navigationView().zStack().text(0).attributes().foregroundColor(), .secondary)
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 5.0)
    }
    
    func testDriverListIsShownAndOthersHidden() throws {
        let sut = FavoriteDriversView()
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.favoriteDrivers = [self.drivers[0], self.drivers[1], self.drivers[2]]
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "text_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).count, 3)
            XCTAssertThrowsError(try view.navigationView().zStack().list(0).forEach(0).navigationLink(4))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 5.0)
    }
    
    func testDriverRowIsRenderedCorrectly() throws {
        let sut = FavoriteDriversView()
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.favoriteDrivers = [self.drivers[0]]
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(0).labelView().view(DriverRow.self).vStack().text(0).string(), "Alexander Albon")
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(0).labelView().view(DriverRow.self).vStack().text(1).string(), "Thai")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 5.0)
    }
}
