//
//  DriverDetailViewUITests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 12/08/24.
//

import XCTest
import ViewInspector
@testable import MVVMPrototype
import SwiftUI
import Cuckoo

final class DriverDetailViewUITests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var raceResults: [Race]!
    var mockVM: MockDriverDetailViewModel!
    var originalVM: DriverDetailViewModel!
    var sut: DriverDetailView!
    
    override func setUp() {
        super.setUp()
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
        let resultsResponse: RaceResultResponse = try! FileUtils.loadJSONData(from: "leclerc_results", withExtension: "json", in: type(of: self))
        raceResults = resultsResponse.mrData.raceTable.races
        
        mockVM = MockDriverDetailViewModel(driver: drivers.first!)
        originalVM = DriverDetailViewModel(driver: drivers.first!)
        mockVM.enableDefaultImplementation(originalVM)
        sut = DriverDetailView(driver: drivers.first!, viewModel: mockVM)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testProgressViewIsShownAndOthersHidden() throws {
        stub(mockVM) { stub in
            when(stub.isLoading.get).thenReturn(true)
        }

        let exp = sut.inspection.inspect() { view in
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
        stub(mockVM) { stub in
            when(stub.errorMessage.get).thenReturn("Test error")
        }
        let exp = sut.inspection.inspect() { view in
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
        stub(mockVM) { stub in
            when(stub.races.get).thenReturn([])
        }
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
    
    func testDriverListIsShownAndOthersHidden() throws {
        stub(mockVM) { stub in
            when(stub.races.get).thenReturn([self.raceResults[0], self.raceResults[1], self.raceResults[2]])
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "detail_text_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
            XCTAssertEqual(try view.list().section(1).forEach(0).count, 3)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testSectionTitlesAreCorrect() throws {
        stub(mockVM) { stub in
            when(stub.races.get).thenReturn([self.raceResults[0]])
        }
        let exp = sut.inspection.inspect() { view in
            XCTAssertEqual(try view.list().section(0).header().text(0).string(), "Driver Information")
            XCTAssertEqual(try view.list().section(1).header().text(0).string(), "Race Results for current season")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testAllInfoRowsAreRendered() throws {
        let exp = sut.inspection.inspect() { view in
            XCTAssertEqual(try view.list().section(0).count, 4)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testResultRowIsRendered() throws {
        stub(mockVM) { stub in
            when(stub.races.get).thenReturn([self.raceResults[0]])
        }
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.races = [self.raceResults[0]]
            XCTAssertNoThrow(try view.list().section(1).forEach(0).view(RaceResultRow.self, 0))
            XCTAssertThrowsError(try view.list().section(1).forEach(0).view(RaceResultRow.self, 1))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testButtonTapChangeIcon() throws {
        stub(mockVM) { stub in
            when(stub.isFavorite.get).thenReturn(false)
        }
        
        let exp1 = sut.inspection.inspect() { view in
            let button = try view.list().toolbar().item(0).button()
            XCTAssertEqual(try button.labelView().image().actualImage().name(), "star")
            try button.tap()
            verify(self.mockVM).toggleFavorite()
            stub(self.mockVM) { stub in
                when(stub.isFavorite.get).thenReturn(true)
            }
        }

        let exp2 = sut.inspection.inspect() { view in
            let button = try view.list().toolbar().item(0).button()
            XCTAssertEqual(try button.labelView().image().actualImage().name(), "star.fill")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 3)
    }
}
