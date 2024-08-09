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

class DriversListViewTests: XCTestCase {
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
        let sut = DriversListView()
        let exp = sut.inspection.inspect() { view in
            XCTAssertFalse(try view.actualView().viewModel.isLoading)
            XCTAssertFalse(try view.actualView().viewModel.errorMessage != nil)
            XCTAssertEqual(try view.actualView().viewModel.drivers, [])
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testProgressViewIsShownAndOthersHidden() throws {
        let sut = DriversListView()
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.isLoading = true
            XCTAssertTrue(try view.actualView().viewModel.isLoading)
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            //XCTAssertTrue(try view.find(viewWithAccessibilityIdentifier: "error_view").isHidden())
            //XCTAssertTrue(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testErrorViewIsShownAndOthersHidden() throws {
        let sut = DriversListView()
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.errorMessage = "Test error"
            //XCTAssertTrue(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "error_view").isHidden())
            XCTAssertEqual(try view.navigationView().zStack().view(ErrorView.self, 0).vStack().image(0).actualImage().name(), "exclamationmark.triangle")
            XCTAssertEqual(try view.navigationView().zStack().view(ErrorView.self, 0).vStack().text(1).string(), "Error")
            XCTAssertEqual(try view.navigationView().zStack().view(ErrorView.self, 0).vStack().text(2).string(), "Test error")
            //XCTAssertTrue(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverListIsShownAndOthersHidden() throws {
        let sut = DriversListView()
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.drivers = self.drivers
            //XCTAssertTrue(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            //XCTAssertTrue(try view.find(viewWithAccessibilityIdentifier: "error_view").isHidden())
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverRowIsRenderedCorrectly() throws {
        let sut = DriversListView()
        let exp = sut.inspection.inspect() { view in
            try view.actualView().viewModel.drivers = self.drivers
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(0).labelView().view(DriverRow.self).vStack().text(0).string(), "Alexander Albon")
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(0).labelView().view(DriverRow.self).vStack().text(1).string(), "Thai")
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(1).labelView().view(DriverRow.self).vStack().text(0).string(), "Fernando Alonso")
            XCTAssertEqual(try view.navigationView().zStack().list(0).forEach(0).navigationLink(1).labelView().view(DriverRow.self).vStack().text(1).string(), "Spanish")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testProgressViewIsShown() throws {
        let view = DriversListView()
        //let viewModel = DriversListViewModel()
        //view.viewModel = viewModel
        let sut = try view.inspect()
        let actualView = try view.inspect().find(DriversListView.self).actualView()
        //viewModel.isLoading = true
        view.viewModel.isLoading = true
        //sut.find(DriverListView.self).actualView().viewModel.isLoading = true
        //XCTAssertTrue(actualView.viewModel.isLoading)
        XCTAssertFalse(try sut.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
    }
    
//    func testInitialState2() throws {
//        //let sut = DriversListView()
//        //let test = try sut.inspect().navigationStack().zStack().find(viewWithAccessibilityIdentifier: "progress_view")
//        //let test = try sut.inspect().find(ViewType.NavigationStack.self).zStack().find(viewWithAccessibilityIdentifier: "progress_view")
//
//        let view = DriversListView()
//        let viewModel = DriversListViewModel()
//        
//        //viewModel.isLoading = true
//        view.viewModel = viewModel
//        let sut = try view.inspect().find(DriversListView.self)
//        print(try sut.find(viewWithAccessibilityIdentifier: "list_view"))
//        //XCTAssertFalse(try sut.actualView().viewModel.isLoading)
//        //try sut.actualView().viewModel.isLoading = true
//        //XCTAssertTrue(try sut.actualView().viewModel.isLoading)
//        //XCTAssertFalse(try sut.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
//        //try sut.actualView().viewModel.isLoading = false
//        XCTAssertFalse(try sut.actualView().viewModel.isLoading)
//        let vstack = try sut.navigationView().vStack()
//        let listView = try sut.find(viewWithAccessibilityIdentifier: "list_view")
//        XCTAssertFalse(listView.isHidden())
//        XCTAssertTrue(listView.isResponsive())
//        //XCTAssertEqual(try listView.list(0).forEach(0).find(viewWithAccessibilityIdentifier: "DriverCell_albon-DriverCell_albon").text().string(), "DASDSADAS")
//        view.viewModel.drivers = drivers
//        XCTAssertEqual(try view.inspect().navigationView().vStack().list(0).forEach(0).navigationLink(0).labelView().view(DriverRow.self).vStack().text(1).string(), "DASDSADAS")
//        //XCTAssertEqual(try sut.navigationView().zStack().list(0).outlineGroup(0).leaf(DriverRow.self).text().string(), "Alexander Albon")
//        //print(try vstack.list(0).find(viewWithAccessibilityIdentifier: "DriverCell_leclerc-DriverCell_leclerc"))
//        //XCTAssertEqual(try sut.navigationView().zStack().list(0).find(navigationLink: "Alexander Albon").labelView().text().string(), "Alexander Albon")
//
//        //XCTAssertEqual(try test.count, 1)
//        //try sut.inspect().navigationStack().zStack().find(viewWithAccessibilityIdentifier: "progress_view")
//        //test.find(ProgressView<_, _>.self)
//        //XCTAssertTrue(try sut.inspect().find(ProgressView.self).isHidden())
//        //XCTAssertTrue(try view.inspect().find(ProgressView.self).isPresent)
//        //XCTAssertFalse(try sut.inspect().find(ErrorView.self).isHidden())
//        //XCTAssertFalse(try view.inspect().find(List<ForEach<[Driver], String, NavigationLink<DriverRow, DriverDetailView>>>.self).isPresent)
//    }
    
//    func testIssue() throws {
//        let view = DriversListView()
//        view.viewModel.drivers = drivers
//        let sut = try view.inspect().find(text: "Alexander Albon")
//        XCTAssertEqual(try sut.parent().pathToRoot, "whatever")
//
//        let sut = try view.inspect().find(MVVMPrototype.DriverRow.self, containing: "Alexander Albon")
//        let listView = try sut.find(viewWithAccessibilityIdentifier: "list_view")
//        XCTAssertEqual(try listView.list(0).navigationLink(0).text().string(), "whatever")
//        XCTAssertEqual(try listView.list(0).forEach(0).navigationLink(0).text().string(), "whatever")
//        XCTAssertEqual(try sut.string(), "whatever")
//    }
}
