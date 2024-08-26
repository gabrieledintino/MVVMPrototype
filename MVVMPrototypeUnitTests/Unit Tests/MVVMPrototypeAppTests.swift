//
//  MVVMPrototypeAppTests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'Intino on 26/08/24.
//

import XCTest
@testable import MVVMPrototype

final class MVVMPrototypeAppTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testOnAppearPerformed() {
        let sut = MVVMPrototypeApp()
        XCTAssertNoThrow(sut.appearSetup())
    }
}
