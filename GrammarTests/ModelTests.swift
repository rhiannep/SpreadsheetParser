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
    
    // Relative cells compute the correct properties
    func testRelativeCell() {
        let cell1 = CellReference(colLabel: "AA", rowLabel: 3)
        let cell = CellReference(context: cell1, rowOffset: 20, colOffset: -1)
        XCTAssertEqual(cell?.absolute, "Z23")
        XCTAssertEqual(cell?.row, 22)
        XCTAssertEqual(cell?.column, 25)
    }
    
    // given a column label, the correct row and column number are computed
    // A1 = 0,0
    func testColumnLetterToNumber() {
        let cell = CellReference(colLabel: "AA", rowLabel: 3)
        XCTAssertEqual(cell.absolute, "AA3")
        XCTAssertEqual(cell.row, 2)
        XCTAssertEqual(cell.column, 26)
    }
    
    // CellReferences can be used as hash keys
    func testHashability() {
        let cell1 = CellReference(colLabel: "AA", rowLabel: 3)
        let cell2 = CellReference(context: cell1, rowOffset: 0, colOffset: 0)
        let cell3 = CellReference(context: cell1, rowOffset: -1, colOffset: 0)
        XCTAssertEqual(cell1, cell2)
        XCTAssertNotEqual(cell2, cell3)
    }
    
    // Constructor and setters for cell content work
    func testCellContents() {
        let cellValue = CellValue()
        cellValue.set(number: 3)
        
        let cell = CellContents(expression: "1+2", value: cellValue)
        
        XCTAssertEqual(cell.expression, "1+2")
        XCTAssertEqual(cell.value.get(), 3)
    }
    
    //test that cells can be inserted and deleted from a dictionary
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
