//
//  PrintAndAssignmentTests.swift
//  SpreadsheetParser
//
//  Created by Rhianne Price on 4/09/17.
//  Copyright © 2017 Rhianne Price. All rights reserved.
//
// Tests for Print and assignment parsing.
//

import XCTest

@testable import SpreadsheetParser

class PrintAndAssignmentTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        // Clear the model between each unit test
        Spreadsheet.theSpreadsheet.clear()
    }
    
    // parsing "A2 := 5" should store the cell value 5 and expression 5 on the model at A2
    func testGRAssignment1() {
        let assignment = GRAssignment()
        let A2 = CellReference(colLabel: "A", rowLabel: 2)
    
        let A2equals5 = "A2 := 5"
        
        XCTAssertEqual(assignment.parse(input: A2equals5), "")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A2).expression, "5")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A2).value.get(), 5)
    }
    
    // parsing "A3 + 1" with nothing in A3 should store the cell value 1 and expression "A3 + 1" on the model at A2
    func testGRAssignment2() {
        let assignment = GRAssignment()
        let A2 = CellReference(colLabel: "A", rowLabel: 2)
    
        let A2equalsA2 = "A2 := A3 + 1"
        XCTAssertEqual(assignment.parse(input: A2equalsA2), "")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A2).expression, "A3+1")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A2).value.get(), 1)
    }
    
    // parsing "A2 := \" hello\"" should store the cell value " hello" and expression " hello" on the model at A2
    func testGRAssignment3() {
        let assignment = GRAssignment()
        let A2 = CellReference(colLabel: "A", rowLabel: 2)
    
        let A2equalsHello = "A2 := \" hello\""
        
        XCTAssertEqual(assignment.parse(input: A2equalsHello), "")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A2).expression, "\" hello\"")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A2).value.describing(), "\" hello\"")
    }
    
    // parsing "A2 := 40*2+2*4hello" should store the cell value 88 and expression 40*2+2*4 on the model at A2
    // parsing "A3 := A2+A2" with A2 = 88 on the model should store the cell value 176 and expression A2+A2 on the model at A3
    func testGRAssignment4() {
        let assignment = GRAssignment()
        let A2 = CellReference(colLabel: "A", rowLabel: 2)
        let A3 = CellReference(colLabel: "A", rowLabel: 3)
        
        let A2equalsTimes = "A2 := 40*2+2*4hello"
        
        XCTAssertEqual(assignment.parse(input: A2equalsTimes), "hello")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A2).expression, "40*2+2*4")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A2).value.get(), 88)
        
        let A3equalsA2 = "A3 := A2+A2"
        XCTAssertEqual(assignment.parse(input: A3equalsA2), "")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A3).expression, "A2+A2")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A3).value.get(), 176)
    }
    
    // Parsing an invalid assignment command should fail
    func testGRAssignment5() {
        let assignment = GRAssignment()
        
        let invalidExpression1 = "A3 := +40*2+2*4hello"
        XCTAssertNil(assignment.parse(input: invalidExpression1))
    }
    
    // Parsing an invalid assignment command should fail
    func testGRAssignment6() {
        let assignment = GRAssignment()
        
        let invalidExpression2 = "r3c0 := +40*2+2*4hello"
        XCTAssertNil(assignment.parse(input: invalidExpression2))
    }
    
    // parsing "A1 := A3*3" with A3 = 4 on the model should store the cell value 12 and expression A3*3 on the model at A1
    func testGRAssignment7() {
        let assignment = GRAssignment()
        let A1 = CellReference(colLabel: "A", rowLabel: 1)
        
        // A1 := A3 * 3 = 12
        XCTAssertEqual(assignment.parse(input: "A3 := 4"), "")
        XCTAssertEqual(assignment.parse(input: "A1 := A3*3"), "")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A1).expression, "A3*3")
        XCTAssertEqual(Spreadsheet.theSpreadsheet.get(A1).value.get(), 12)
    }
    
    func testGRPrint() {
        // Check console to check that printed output is correct
        
        // Add to model using assignment commands
        // Z1 = 21, Z2 = 20, Z3 = Z1+Z2 = 41
        XCTAssertEqual(GRAssignment().parse(input: "Z1 := 4*5+1 Z2 := 20"), "")
        XCTAssertEqual(GRAssignment().parse(input: "Z3 := r-2c0+Z2"), "")
        
        print("Check following output:")
        
        // printing an expression should print the expression/value
        // in this case the value and the expression are the same thing.
        XCTAssertEqual(GRPrint().parse(input: "print_expr \" hello\""), "")
        XCTAssertEqual(GRPrint().parse(input: "print_value \" hello\""), "")
        
        // Printing the expression Z1+Z2 should print just that,
        // Printing the value Z1+Z2 with Z1 = 21 nd Z2 = 20 on the model should print the value 41
        XCTAssertEqual(GRPrint().parse(input: "print_expr Z1+Z2 print_value Z1+Z2" ), "")
        
        // Printing the expression of a cell should print the expression in tht cell on the model.
        // Z3 can be expanded to Z1+Z2, which is 41
        XCTAssertEqual(GRPrint().parse(input: "print_expr Z3 print_value Z3"), "")
        
        
        // Printing the expression 6*7+2 should print just that,
        // Printing the value 6+7+2 should print 15
        XCTAssertEqual(GRPrint().parse(input: "print_expr 6*7+2 print_value 6+7+2"), "")
        
        // Z2 = 3, Z3 = Z1+Z2 = 22, Z3 + 1 = Z1+Z2+1 = 21+3+1 = 25
        XCTAssertEqual(GRAssignment().parse(input: "Z2 := 3"), "")
        XCTAssertEqual(GRPrint().parse(input: "print_value Z3+1"), "")
        
        // an invalid print statement should fail
        XCTAssertNil(GRPrint().parse(input: "Print_expr 34*2"))
    }
    
    // Spreadsheet should be parsed left to right
    // A1 := 12
    // A2 := A1 + 2 = 14
    // A3 := A2 + 1 = 15
    // print_expr A3 should print A2+1
    // print value A3 should print 15
    //
    // A1 is then changed to 13, and the should be carried through to A3
    // print_expr A3 should print A2+1
    // print value A3 should print 16
    //
    // A2 is then changed to A1-2 = 13-2 = 11, and the should be carried through to A3
    // print_expr A3 should print A2+1
    // print value A3 should print 12
    func testGRSpreadsheetParsing() {
        // check console for correct output
        let spreadsheet = GRSpreadsheet()
        
        print("Check following output:")
        
        let tripleRef = "A1 := 12 A2 := A1+2 A3 := A2+1 print_expr A3 print_value A3 A1 := 13 print_expr A3 print_value A3 A2 := A1+-2 print_expr A3 print_value A3"
        
        XCTAssertEqual(spreadsheet.parse(input: tripleRef), "")
        
    }

}
