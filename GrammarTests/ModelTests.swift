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

    func testRelativeCell() {
        let cell1 = CellReference(colLabel: "AA", rowLabel: 3)
        let cell = CellReference(context: cell1, rowOffset: 20, colOffset: -1)
        XCTAssertEqual(cell.absolute, "Z23")
        XCTAssertEqual(cell.row, 22)
        XCTAssertEqual(cell.column, 25)
    }
    
    func testColumnLetterToNumber() {
        let cell = CellReference(colLabel: "AA", rowLabel: 3)
        XCTAssertEqual(cell.absolute, "AA3")
        XCTAssertEqual(cell.row, 2)
        XCTAssertEqual(cell.column, 26)
    }
    
    func testHashability() {
        let cell1 = CellReference(colLabel: "AA", rowLabel: 3)
        let cell2 = CellReference(context: cell1, rowOffset: 0, colOffset: 0)
        let cell3 = CellReference(context: cell1, rowOffset: -1, colOffset: 0)
        XCTAssertEqual(cell1, cell2)
        XCTAssertNotEqual(cell2, cell3)
    }
    
    func testCellContents() {
        let cellValue = CellValue()
        cellValue.set(number: 3)
        
        let cell = CellContents(expression: "1+2", value: cellValue)
        
        XCTAssertEqual(cell.expression, "1+2")
        XCTAssertEqual(cell.value.get(), 3)
    }
    
    func testSimpleDictionary() {
        // A dictionary of CellContents indexed by CellReferences
        var cells = [CellReference: CellContents]()
        let cellValue = CellValue()
        cellValue.set(number: 3)
        
        // Add a value and expression to cell to AA4
        let reference1 = CellReference(colLabel: "AA", rowLabel: 4)
        cells[CellReference(colLabel: "AA", rowLabel: 4)] = CellContents(expression: "1*2", value: cellValue)
        XCTAssertEqual(cells[reference1]!.value.get(), 3)
        
        cellValue.set(number: 12)
        // Change the contents of AA4 and check that the contents have changed
        cells[reference1] = CellContents(expression: "whatever", value: cellValue)
        XCTAssertEqual(cells[reference1]!.value.get(), 12)
        XCTAssertEqual(cells[CellReference(colLabel: "AA", rowLabel: 4)]!.expression, "whatever")
        
        // There should only be one cell so far
        XCTAssertEqual(cells.count, 1)
        
        cellValue.set(number: 3)
        // Add another cell at Z3 and copy the contents of AA3
        cells[CellReference(colLabel: "Z", rowLabel: 3)] = cells[reference1]
        // Change the contents of AA3
        cells[reference1] = CellContents(expression: "whatever else", value: cellValue)
        // Check Z3 still has the old contents of AA3
        XCTAssertEqual(cells[CellReference(colLabel: "Z", rowLabel: 3)]!.expression, "whatever")
        // Should only be 2 cells now
        XCTAssertEqual(cells.count, 2)
    }
}
