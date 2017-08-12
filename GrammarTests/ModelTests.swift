//
//  ModelTests.swift
//  SpreadsheetParser
//
//  Created by Rhianne Price on 12/08/17.
//  Copyright © 2017 Rhianne Price. All rights reserved.
//

import XCTest

@testable import SpreadsheetParser

class ModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testColumnNumberToLetter() {
        let cell = CellReference(row: 3, column: 26)
        XCTAssertEqual(cell.absolute, "AA3")
        XCTAssertEqual(cell.relative, "r3c26")
    }
    
    func testColumnLetterToNumber() {
        let cell = CellReference(columnRef: "AA", rowNumber: 3)
        XCTAssertEqual(cell.absolute, "AA3")
        XCTAssertEqual(cell.relative, "r3c26")
    }
    
    func testHashability() {
        let cell1 = CellReference(columnRef: "AA", rowNumber: 3)
        let cell2 = CellReference(row: 3, column: 26)
        let cell3 = CellReference(row: 3, column: 25)
        XCTAssertEqual(cell1.hashValue, cell2.hashValue)
        XCTAssertEqual(cell1, cell2)
        XCTAssertNotEqual(cell2, cell3)
    }
    
    func testCellContents() {
        let cell = CellContents(experssion: "1+2", value: 3)
        
        XCTAssertEqual(cell.experssion, "1+2")
        XCTAssertEqual(cell.value, 3)
    }
}
