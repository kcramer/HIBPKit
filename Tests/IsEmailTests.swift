//
//  IsEmailTests.swift
//  HIBPKit
//
//  Created by Kevin on 11/17/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import XCTest
import HIBPKit

class IsEmailTests: XCTestCase {
    func testValidEmail() {
        XCTAssert(
            HIBPService.isEmail("john.doe@example.com"),
            "Should be a valid email!"
        )
    }

    func testJustUserName() {
        XCTAssert(
            !HIBPService.isEmail("john.doe"),
            "Should be an invalid email!"
        )
    }

    func testMissingTLD() {
        XCTAssert(
            !HIBPService.isEmail("john.doe@example"),
            "Should be an invalid email!"
        )
    }

    func testEmptyString() {
        XCTAssert(
            !HIBPService.isEmail(""),
            "Should be an invalid email!"
        )
    }
}
