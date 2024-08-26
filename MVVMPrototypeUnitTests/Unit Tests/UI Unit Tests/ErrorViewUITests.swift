//
//  ErrorViewUITests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 06/08/24.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import MVVMPrototype


class ErrorViewUITests: XCTestCase {
    
    func testErrorViewContent() throws {
        let errorMessage = "Test error message"
        let errorView = ErrorView(message: errorMessage)
        
        let vStack = try errorView.inspect().vStack()
        
        // Test the image
        let image = try vStack.image(0)
        XCTAssertEqual(try image.actualImage().name(), "exclamationmark.triangle")
        XCTAssertEqual(try image.font(), .largeTitle)
        XCTAssertEqual(try image.foregroundColor(), .red)
        
        // Test the "Error" text
        let errorText = try vStack.text(1)
        XCTAssertEqual(try errorText.string(), "Error")
        XCTAssertEqual(try errorText.attributes().font(), .title)
        
        // Test the error message text
        let messageText = try vStack.text(2)
        XCTAssertEqual(try messageText.string(), errorMessage)
        XCTAssertEqual(try messageText.multilineTextAlignment(), .center)
    }
}
