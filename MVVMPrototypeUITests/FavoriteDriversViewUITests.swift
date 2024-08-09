//
//  FavoriteDriversViewUITests.swift
//  MVVMPrototypeUITests
//
//  Created by Gabriele D'intino (EXT) on 07/08/24.
//

import XCTest
@testable import MVVMPrototype

class FavoriteDriversViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testInitialViewRendering() throws {
        // Check if the navigation title is correct
        XCTAssertTrue(app.navigationBars["Favorite Drivers"].exists)

        // Check if the search bar is present
        XCTAssertTrue(app.searchFields["Search drivers"].exists)
    }
    
    func testEmptyStateMessageDisplayed() throws {
        // Assuming we can force an empty state
        let emptyStateMessage = app.staticTexts["No favorite drivers yet"]
        XCTAssertTrue(emptyStateMessage.exists, "Empty state message should be displayed when there are no favorite drivers")
    }
    
    func testFavoriteDriversListDisplayed() throws {
        // Assuming we have some favorite drivers
        let favoriteDriversList = app.tables.firstMatch
        XCTAssertTrue(favoriteDriversList.exists, "Favorite drivers list should be displayed when there are favorite drivers")
        
        // Check if there are cells in the list
        let cells = favoriteDriversList.cells
        XCTAssertGreaterThan(cells.count, 0, "There should be at least one driver in the favorites list")
    }
    
    func testNavigationToDriverDetail() throws {
        // Assuming we have at least one favorite driver
        let favoriteDriversList = app.tables.firstMatch
        let firstDriver = favoriteDriversList.cells.element(boundBy: 0)
        
        firstDriver.tap()
        
        // Assuming the detail view has a specific identifier or title
        let detailView = app.otherElements["DriverDetailView"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 2), "Driver detail view should be displayed after tapping a driver")
    }
    
    func testRemoveFavoriteDriver() throws {
        // Assuming we have at least one favorite driver
        let favoriteDriversList = app.tables.firstMatch
        let initialCellCount = favoriteDriversList.cells.count
        
        // Swipe to delete the first cell
        let firstDriver = favoriteDriversList.cells.element(boundBy: 0)
        firstDriver.swipeLeft()
        
        // Tap the delete button
        app.buttons["Delete"].tap()
        
        // Check if the cell count has decreased
        let newCellCount = favoriteDriversList.cells.count
        XCTAssertEqual(newCellCount, initialCellCount - 1, "The number of favorite drivers should decrease by 1 after removal")
    }
}
