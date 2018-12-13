//
//  HIBPKitTests.swift
//  HIBPKitTests
//
//  Created by Kevin on 6/4/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import XCTest
import HIBPKit

class PasswordByRangeTests: XCTestCase {
    let service = HIBPService(userAgent: TestingConstants.userAgent)
    var delay = false

    override func setUp() {
        super.setUp()
        // Wait 2 seconds in between calls to avoid the retry error.
        if delay {
            Thread.sleep(forTimeInterval: 2)
        }
    }

    override func tearDown() {
        super.tearDown()
        // Once one test is ran, initiate a delay for subsequent tests.
        delay = true
    }

    func testPassword() {
        let exp = expectation(description: "Getting results for passwordByRange.")
        service.passwordByRange(password: "password") { result in
            switch result {
            case .success(let count):
                XCTAssertGreaterThan(count, 3000000, "Count should be greater than.")
            case .failure(let error):
                XCTFail("Password should be found! Error: \(error)")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testEmptyPassword() {
        let exp = expectation(description: "Getting results for passwordByRange.")
        service.passwordByRange(password: "") { result in
            switch result {
            case .success(let count):
                XCTAssertEqual(count, 0, "Count should be zero!")
            case .failure(let error):
                XCTFail("Empty password should NOT return an error! Error: \(error)")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
}
