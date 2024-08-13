//
//  DriverDetailViewIntegrationTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 12/08/24.
//

import XCTest
import ViewInspector
@testable import MVVMPrototype
import SwiftUI

final class DriverDetailViewIntegrationTests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var raceResults: [Race]!
    
    override func setUp() {
        super.setUp()
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "FavoriteDrivers")
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
        let resultsResponse: RaceResultResponse = try! FileUtils.loadJSONData(from: "leclerc_results", withExtension: "json", in: type(of: self))
        raceResults = resultsResponse.mrData.raceTable.races
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitialState() throws {
        let sut = DriverDetailView(driver: drivers.first!)
        let exp = sut.inspection.inspect() { view in
            XCTAssertFalse(try view.actualView().viewModel.isLoading)
            XCTAssertFalse(try view.actualView().viewModel.errorMessage != nil)
            XCTAssertEqual(try view.actualView().viewModel.races, [])
            XCTAssertFalse(try view.actualView().viewModel.isFavorite)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }

    func testProgressViewIsShownAndOthersHidden() throws {
        let sut = DriverDetailView(driver: drivers.first!)
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.isLoading = true
            XCTAssertTrue(try view.actualView().viewModel.isLoading)
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "detail_text_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testErrorViewIsShownAndOthersHidden() throws {
        let sut = DriverDetailView(driver: drivers.first!)
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.errorMessage = "Test error"
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "error_view").isHidden())
            XCTAssertEqual(try view.list().section(1).view(ErrorView.self, 0).vStack().image(0).actualImage().name(), "exclamationmark.triangle")
            XCTAssertEqual(try view.list().section(1).view(ErrorView.self, 0).vStack().text(1).string(), "Error")
            XCTAssertEqual(try view.list().section(1).view(ErrorView.self, 0).vStack().text(2).string(), "Test error")
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "detail_text_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))

        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverListIsEmptyShowsText() throws {
        let sut = DriverDetailView(driver: drivers.first!)
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "detail_text_view").isHidden())
            XCTAssertEqual(try view.list().section(1).text(0).string(), "No race results available.")
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverListIsLoadedAndShownAndOthersHidden() throws {
        let sut = DriverDetailView(driver: drivers.first!)
        let exp = sut.inspection.inspect(after: 5.0) { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "detail_text_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
            XCTAssertTrue(try view.list().section(1).forEach(0).count > 0)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 5.0)
    }
    
    func testButtonTapChangeIcon() throws {
        let sut = DriverDetailView(driver: drivers.first!)
        let exp1 = sut.inspection.inspect() { view in
            let button = try view.list().toolbar().item(0).button()
            XCTAssertEqual(try button.labelView().image().actualImage().name(), "star")
            try button.tap()
        }

        let exp2 = sut.inspection.inspect() { view in
            let button = try view.list().toolbar().item(0).button()
            XCTAssertEqual(try button.labelView().image().actualImage().name(), "star.fill")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 3)
    }
}
