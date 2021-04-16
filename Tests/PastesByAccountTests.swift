//
//  PastesByAccountTests.swift
//  HIBPKitTests
//
//  Created by Kevin on 8/8/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import XCTest
import HIBPKit

class PastesByAccountTests: XCTestCase {
    let service = HIBPService(userAgent: TestingConstants.userAgent,
                              apiKey: "",
                              baseURL: nil)

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

    func testFound() {
        let exp = expectation(description: "Getting results for pastes for account.")
        service.pastes(for: "john.doe@example.com") { result in
            switch result {
            case .success(let pastes):
                XCTAssertGreaterThan(pastes.count, 14, "Count should be at least 15.")
            case .failure(let error):
                XCTFail("Email should be found! Error: \(error)")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testNotFound() {
        let exp = expectation(description: "Getting results for pastes for account.")
        service.pastes(for: "fjdskafjkafjdaaa@example.com") { result in
            switch result {
            case .success:
                XCTFail("Email should NOT be found!")
            case .failure(let error):
                // Should return a notFound error, if not fail.
                guard case .notFound = error else {
                    XCTFail("Should not return an error: \(error)")
                    return
                }
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
}
