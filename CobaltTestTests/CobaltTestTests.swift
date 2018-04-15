//
//  CobaltTestTests.swift
//  CobaltTestTests
//
//  Created by Antonio Strijdom on 11/04/2018.
//  Copyright © 2018 Antonio Strijdom. All rights reserved.
//

import XCTest
@testable import CobaltTest

class CobaltTestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCharactersWebMethod() {
        let expectation = XCTestExpectation(description: "characters found")
        let controller = CharactersWebMethod()
        controller.getCharacters(withLimit: 50) { (result, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    
    func testCharactersWebMethodLimit() {
        let expectation = XCTestExpectation(description: "characters found")
        let controller = CharactersWebMethod()
        controller.getCharacters(withLimit: 10) { (result, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            if let chars = result?.data?.results {
                XCTAssert(chars.count == 10, "Should have only returned 10 characters")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCharactersWebMethodTransform() {
        let expectation = XCTestExpectation(description: "characters found")
        let controller = CharactersWebMethod()
        controller.getCharacters(withLimit: 10) { (result, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            if let chars = MarvelCharacter.CharactersFromWebMethodResult(result: result) {
                XCTAssert(chars.count == 10, "Should have transformed 10 characters")
                for char in chars {
                    XCTAssert(!char.name.isEmpty, "All characters should have a name")
                }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
