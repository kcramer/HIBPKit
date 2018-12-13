//
//  BreachesByAccountTests.swift
//  HIBPKitTests
//
//  Created by Kevin on 6/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import XCTest
import HIBPKit

class BreachesByAccountTests: XCTestCase {
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

    func testFound() {
        let exp = expectation(description: "Getting results for breaches for account.")
        service.breaches(for: "john.doe@example.com") { result in
            switch result {
            case .success(let breaches):
                XCTAssertGreaterThan(breaches.count, 8, "Count should be > 8.")
            case .failure(let error):
                XCTFail("Account should be found! Error: \(error)")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testNotFound() {
        let exp = expectation(description: "Getting results for breaches for account.")
        service.breaches(for: "jfsdafsdfdsiri@example.com") { result in
            switch result {
            case .success:
                XCTFail("Account should NOT be found!")
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
