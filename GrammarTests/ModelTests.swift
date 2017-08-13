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
//    var cells : [CellReference: CellContents]
    
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
    
    func testInsertion() {
        // A dictionary of CellContents indexed by CellReferences
        var cells = [CellReference: CellContents]()
        
        // Add a value and expression to cell to r3c26 and the same value is in AA3
        cells[CellReference(row: 3, column: 26)] = CellContents(experssion: "1*2", value: 3)
        let reference1 = CellReference(columnRef: "AA", rowNumber: 3)
        XCTAssertEqual(cells[reference1]!.value, 3)
        
        // Change the contents of AA3/r3c26 and check that the contents have changed
        cells[reference1] = CellContents(experssion: "whatever", value: 12)
        XCTAssertEqual(cells[CellReference(row: 3, column: 26)]!.value, 12)
        XCTAssertEqual(cells[CellReference(columnRef: "AA", rowNumber: 3)]!.experssion, "whatever")
        
        // There should only be one cell so far because AA3 and r3c26 refer to the same cell
        XCTAssertEqual(cells.count, 1)
        
        // Add another cell at Z3 and copy the contents of AA3
        cells[CellReference(row: 3, column: 25)] = cells[reference1]
        // Change the contents of AA3
        cells[reference1] = CellContents(experssion: "whatever else", value: 22)
        // Check Z3 still has the old contents of AA3
        XCTAssertEqual(cells[CellReference(columnRef: "Z", rowNumber: 3)]!.experssion, "whatever")
        // Should only be 2 cells now
        XCTAssertEqual(cells.count, 2)
        
        
    }
}
