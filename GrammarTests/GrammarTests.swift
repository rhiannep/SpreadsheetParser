//
//  GrammarTests.swift
//  GrammarTests
//
//  Created by Rhianne Price on 11/08/17.
//  Copyright © 2017 Rhianne Price. All rights reserved.
//

import XCTest

@testable import SpreadsheetParser

class GrammarTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        
        // Clear the model between each unit test
        GrammarRule.cells.clear()
    }
    
    func testGRIntegerParsing() {
        let aGRInteger = GRInteger()
        
        // Parsing "2gd6" should consume and record the "2", and leave the "gd6"
        XCTAssertEqual(aGRInteger.parse(input: "2gd6"), "gd6")
        XCTAssertEqual(aGRInteger.calculatedValue!, 2)
        XCTAssertEqual(aGRInteger.stringValue, "2")
        
        // Parsing "-26" should consume and record the "-26", and leave nothing
        XCTAssertEqual(aGRInteger.parse(input: "-26"), "")
        XCTAssertEqual(aGRInteger.calculatedValue!, -26)
        XCTAssertEqual(aGRInteger.stringValue, "-26")
        
        // Parsing "NaN" should consume nothing, and leave nothing
        XCTAssertNil(aGRInteger.parse(input: "NaN"))
        XCTAssertNil(aGRInteger.calculatedValue)
        XCTAssertNil(aGRInteger.stringValue)
    }
    
    func testGRPositiveIntegerParsing() {
        let aGRPositiveInteger = GRPositiveInteger()
        
        // Parsing "-2asjd7f7" should consume nothing, and leave nothing
        XCTAssertNil(aGRPositiveInteger.parse(input: "-2asjd7f7"))
        XCTAssertNil(aGRPositiveInteger.calculatedValue)
        XCTAssertNil(aGRPositiveInteger.stringValue)
        
        // Parsing "2gd6" should consume and record the "2", and leave the "gd6"
        XCTAssertEqual(aGRPositiveInteger.parse(input: "2gd6"), "gd6")
        XCTAssertEqual(aGRPositiveInteger.calculatedValue!, 2)
        XCTAssertEqual(aGRPositiveInteger.stringValue, "2")
    }
    
    func testGRLiteralParsing() {
        // Parsing "b*a" should consume and record the "b", and leave the "*a"
        let b = GRLiteral(literal: "b")
        XCTAssertEqual(b.parse(input: "b*a"), "*a")
        XCTAssertNil(b.calculatedValue)
        XCTAssertEqual(b.stringValue, "b")
        
        // Parsing "hey" should consume nothing, and leave nothing
        XCTAssertNil(b.parse(input: "hey"))
        XCTAssertNil(b.calculatedValue)
        XCTAssertNil(b.stringValue)
        
        let quoteMark = GRLiteral(literal: "\"")
        
        // Parsing "" oh how fast" should consume and record the """, and leave the " oh how fast"
        XCTAssertEqual(quoteMark.parse(input: "\" oh how fast"), " oh how fast")
        XCTAssertNil(quoteMark.calculatedValue)
        XCTAssertEqual(quoteMark.stringValue, "\"")
    }
    
    func testGRUpperAlphaStringParsing() {
        let aGRUpperAlphaString = GRUpperAlphaString()
        
        // Parsing "BDahs" should consume and record the "BD", and leave the "ahs"
        XCTAssertEqual(aGRUpperAlphaString.parse(input: "BDahs"), "ahs")
        XCTAssertNil(aGRUpperAlphaString.calculatedValue)
        XCTAssertEqual(aGRUpperAlphaString.stringValue, "BD")
        
        // Parsing "23" should consume nothing, and leave nothing
        XCTAssertNil(aGRUpperAlphaString.parse(input: "23"))
        XCTAssertNil(aGRUpperAlphaString.calculatedValue)
        XCTAssertNil(aGRUpperAlphaString.stringValue)
    }
    
    func testGRStringNoQuoteParsing() {
        let aGRStringNoQuote = GRStringNoQuote()
        
        // Parsing ""hello hello" should consume nothing, and leave nothing
        let hasAQuote = "\" hello hello"
        XCTAssertNil(aGRStringNoQuote.parse(input: hasAQuote))
        XCTAssertNil(aGRStringNoQuote.calculatedValue)
        XCTAssertNil(aGRStringNoQuote.stringValue)
        
        // Parsing " hello 25 hello  " should consume and record the " hello 25 hello  ", and leave the empty string
        let noQuote = " hello 25 hello  "
        XCTAssertEqual(aGRStringNoQuote.parse(input: noQuote), "")
        XCTAssertNil(aGRStringNoQuote.calculatedValue)
        XCTAssertEqual(aGRStringNoQuote.stringValue, noQuote)
    }
    
    func testGRQuotedStringParsing() {
        let aGRQuotedString = GRQuotedString()
        
        // Parsing "" hello hello  " 20" should consume and record the "" hello hello  "", and leave " 20"
        let aStringWithQuotes = "\" hello hello  \" 20"
        XCTAssertEqual(aGRQuotedString.parse(input: aStringWithQuotes), " 20")
        XCTAssertNil(aGRQuotedString.calculatedValue)
        XCTAssertEqual(aGRQuotedString.stringValue, "\" hello hello  \"")
        
        // Parsing ""hello hello" should consume nothing, and leave nothing
        let hasAQuote = "\" hello hello"
        XCTAssertNil(aGRQuotedString.parse(input: hasAQuote))
        XCTAssertNil(aGRQuotedString.calculatedValue)
        XCTAssertNil(aGRQuotedString.stringValue)
        
        // Parsing " hello 25 hello  " should consume nothing, and leave nothing
        let noQuote = " hello 25 hello  "
        XCTAssertNil(aGRQuotedString.parse(input: noQuote))
        XCTAssertNil(aGRQuotedString.calculatedValue)
        XCTAssertNil(aGRQuotedString.stringValue)

    }
    
    func testGRColumnLabelParsing() {
        let aGRColumnLabel = GRColumnLabel()
        
        // Parsing "AB20" should consume and record the "AB", and leave the "20"
        let validLabel = "AB20"
        XCTAssertEqual(aGRColumnLabel.parse(input: validLabel), "20")
        XCTAssertNil(aGRColumnLabel.calculatedValue)
        XCTAssertEqual(aGRColumnLabel.stringValue, "AB")
        
        // Parsing "zz20" should consume nothing, and leave nothing
        let invalidLabel = "zz20"
        XCTAssertNil(aGRColumnLabel.parse(input: invalidLabel))
        XCTAssertNil(aGRColumnLabel.calculatedValue)
        XCTAssertNil(aGRColumnLabel.stringValue)
    }
    
    func testGRRowNumberParsing() {
        let aGRRowNumber = GRRowNumber()
        
        // Parsing "20000-" should consume and record the "20000", and leave the empty string
        // Calculated value should be 20000
        let validRowNumber = "20000-"
        XCTAssertEqual(aGRRowNumber.parse(input: validRowNumber), "-")
        XCTAssertEqual(aGRRowNumber.calculatedValue, 20000)
        XCTAssertEqual(aGRRowNumber.stringValue, "20000")
        
        // Parsing "-2000" should consume nothing, and leave nothing
        let invalidRowNumber1 = "-2000"
        XCTAssertNil(aGRRowNumber.parse(input: invalidRowNumber1))
        XCTAssertNil(aGRRowNumber.calculatedValue)
        XCTAssertNil(aGRRowNumber.stringValue)
        
        // Parsing "NaN" should consume nothing, and leave nothing
        let invalidRowNumber2 = "NaN"
        XCTAssertNil(aGRRowNumber.parse(input: invalidRowNumber2))
        XCTAssertNil(aGRRowNumber.calculatedValue)
        XCTAssertNil(aGRRowNumber.stringValue)
    }
    
    func testProductTermTailParsing() {
        let aGRproductTermTail = GRProductTermTail()
        
        // Parsing "*3" should consume and record the "*3", and leave the empty string
        // Calculated value should be 3
        let times3 = "*3"
        XCTAssertEqual(aGRproductTermTail.parse(input: times3), "")
        XCTAssertEqual(aGRproductTermTail.calculatedValue, 3)
        XCTAssertEqual(aGRproductTermTail.stringValue, times3)
        
        // Parsing "*3*3*4*2+7" should consume and record the "*3*3*4*2", and leave "+7"
        // Calculated value should be 3*3*4*2 = 72
        let timesTwice = "*3*3*4*2+7"
        XCTAssertEqual(aGRproductTermTail.parse(input: timesTwice), "+7")
        XCTAssertEqual(aGRproductTermTail.calculatedValue, 72)
        XCTAssertEqual(aGRproductTermTail.stringValue, "*3*3*4*2")
        
        // Parsing "+7" should consume nothing, and leave nothing
        let plus7 = "+7"
        XCTAssertEqual(aGRproductTermTail.parse(input: plus7), "+7")
        XCTAssertNil(aGRproductTermTail.calculatedValue)
        XCTAssertNil(aGRproductTermTail.stringValue)
        
        // With Z1/r1c25 on the model, Parsing "*5*Z1" should consume and record the "*5*Z1", and leave the empty string
        // With the value in Z1/r1c25 being 6, calculated value should be 5*6 = 30
        GrammarRule.cells.add(CellReference(row: 0, column: 25), CellContents(expression: "2*3", value: 6))
        let timesCellRef1 = "*5*Z1"
        XCTAssertEqual(aGRproductTermTail.parse(input: timesCellRef1), "")
        XCTAssertEqual(aGRproductTermTail.calculatedValue, 30)
        XCTAssertEqual(aGRproductTermTail.stringValue, timesCellRef1)
        
        // Parsing "*5*Z2" should consume and record the "*5*Z2", and leave the empty string
        // With Z2/r2c25 not on the model, calculated value should be 5*0 = 0
        let timesCellRef2 = "*5*Z2"
        XCTAssertEqual(aGRproductTermTail.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRproductTermTail.calculatedValue, 0)
        XCTAssertEqual(aGRproductTermTail.stringValue, timesCellRef2)
    }
    
    func testProductTermParsing() {
        let aGRproductTerm = GRProductTerm()
        
        // Parsing "3" should consume and record the "3", and leave the empty string
        // Calculated value should be 3
        let num = "3"
        XCTAssertEqual(aGRproductTerm.parse(input: num), "")
        XCTAssertEqual(aGRproductTerm.calculatedValue, 3)
        XCTAssertEqual(aGRproductTerm.stringValue, num)
        
        // Parsing "3*3*4*2+7" should consume and record the "3*3*4*2", and leave "+7"
        // Calculated value should be 3*3*4*2 = 72
        let timesTwice = "3*3*4*2+7"
        XCTAssertEqual(aGRproductTerm.parse(input: timesTwice), "+7")
        XCTAssertEqual(aGRproductTerm.calculatedValue, 72)
        XCTAssertEqual(aGRproductTerm.stringValue, "3*3*4*2")
        
        // Parsing "*7" should consume nothing, and leave nothing
        let times7 = "*7"
        XCTAssertNil(aGRproductTerm.parse(input: times7))
        XCTAssertNil(aGRproductTerm.calculatedValue)
        XCTAssertNil(aGRproductTerm.stringValue)
        
        // Parsing "5*Z1*10" should consume and record the "5*Z1*10", and leave the empty string
        // With the value in Z1/r1c25 being 6, calculated value should be 5*6*10 = 300
        GrammarRule.cells.add(CellReference(row: 0, column: 25), CellContents(expression: "2*3", value: 6))
        let timesCellRef1 = "5*Z1*10"
        XCTAssertEqual(aGRproductTerm.parse(input: timesCellRef1), "")
        XCTAssertEqual(aGRproductTerm.calculatedValue, 300)
        XCTAssertEqual(aGRproductTerm.stringValue, timesCellRef1)
        
        // Parsing "5*Z2*10" should consume and record "5*Z2*10", and leave the empty string
        // With Z2/r2c25 not on the model, calculated value should be 5*0*10 = 0
        let timesCellRef2 = "5*Z2*10"
        XCTAssertEqual(aGRproductTerm.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRproductTerm.calculatedValue, 0)
        XCTAssertEqual(aGRproductTerm.stringValue, timesCellRef2)
    }
    
    func testExpressionTailParsing() {
        let aGRExpressionTail = GRExpressionTail()
        
        // Parsing "3" should consume and record the "3", and leave the empty string
        // Calculated value should be 3
        let plus3 = "+3"
        XCTAssertEqual(aGRExpressionTail.parse(input: plus3), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue, 3)
        XCTAssertEqual(aGRExpressionTail.stringValue, plus3)
        
        // Parsing "+1+2+3+4*7" should consume and record the "+1+2+3+4*7", and leave the empty string
        // Calculated value should be 3*3*4*2 = 72
        let plusTwice = "+1+2+3+4*7"
        XCTAssertEqual(aGRExpressionTail.parse(input: plusTwice), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue, 34)
        XCTAssertEqual(aGRExpressionTail.stringValue, plusTwice)
        
        let plusTwice2 = "+1*2+3+4*7"
        XCTAssertEqual(aGRExpressionTail.parse(input: plusTwice2), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue, 33)
        XCTAssertEqual(aGRExpressionTail.stringValue, plusTwice2)
        
        // Parsing "*7" should consume nothing, and leave "*7" (Epsilon parse)
        let times7 = "*7"
        XCTAssertEqual(aGRExpressionTail.parse(input: times7), times7)
        XCTAssertNil(aGRExpressionTail.calculatedValue)
        XCTAssertNil(aGRExpressionTail.stringValue)
        
        GrammarRule.cells.add(CellReference(row: 0, column: 25), CellContents(expression: "2*3", value: 6))
        GrammarRule.cells.add(CellReference(row: 1, column: 26), CellContents(expression: "2*3", value: 2))
        let timesCellRef1 = "+5*Z1*r1c26"
        XCTAssertEqual(aGRExpressionTail.parse(input: timesCellRef1), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue, 60)
        XCTAssertEqual(aGRExpressionTail.stringValue, timesCellRef1)
        
        let timesCellRef2 = "+5*C1*r1c26+8"
        XCTAssertEqual(aGRExpressionTail.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue, 8)
        XCTAssertEqual(aGRExpressionTail.stringValue, timesCellRef2)
    }
    
    func testExpressionParsing() {
        let aGRExpression = GRExpression()
        
        let three = "3"
        XCTAssertEqual(aGRExpression.parse(input: three), "")
        XCTAssertEqual(aGRExpression.calculatedValue, 3)
        XCTAssertEqual(aGRExpression.stringValue, three)
        
        let longExpression1 = "1+2+3+4*7"
        XCTAssertEqual(aGRExpression.parse(input: longExpression1), "")
        XCTAssertEqual(aGRExpression.calculatedValue, 34)
        XCTAssertEqual(aGRExpression.stringValue, longExpression1)
        
        let longExpression2 = "1+2*3+4*7hello"
        XCTAssertEqual(aGRExpression.parse(input: longExpression2), "hello")
        XCTAssertEqual(aGRExpression.calculatedValue, 35)
        XCTAssertEqual(aGRExpression.stringValue, "1+2*3+4*7")
        
        // Parsing "+7" should consume nothing, and leave nothing
        let plus7 = "+7"
        XCTAssertNil(aGRExpression.parse(input: plus7))
        XCTAssertNil(aGRExpression.calculatedValue)
        XCTAssertNil(aGRExpression.stringValue)
        
        let aStringWithQuotes = "\"  **any old string\""
        XCTAssertEqual(aGRExpression.parse(input: aStringWithQuotes), "")
        XCTAssertEqual(aGRExpression.calculatedValue, 0)
        XCTAssertEqual(aGRExpression.stringValue, aStringWithQuotes)
        
        let aStringWithNoQuotes = "  **any old string"
        XCTAssertNil(aGRExpression.parse(input: aStringWithNoQuotes))
        XCTAssertNil(aGRExpression.calculatedValue)
        XCTAssertNil(aGRExpression.stringValue)
        
        GrammarRule.cells.add(CellReference(row: 0, column: 25), CellContents(expression: "2*3", value: 6))
        GrammarRule.cells.add(CellReference(row: 1, column: 26), CellContents(expression: "2*3", value: 2))
        let timesCellRef1 = "5*Z1*r1c26+"
        XCTAssertEqual(aGRExpression.parse(input: timesCellRef1), "+")
        XCTAssertEqual(aGRExpression.calculatedValue, 60)
        XCTAssertEqual(aGRExpression.stringValue, "5*Z1*r1c26")
        
        let timesCellRef2 = "5*C1*r1c26+8"
        XCTAssertEqual(aGRExpression.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRExpression.calculatedValue, 8)
        XCTAssertEqual(aGRExpression.stringValue, timesCellRef2)
        
        let justACellReference = "Z1"
        XCTAssertEqual(aGRExpression.parse(input: justACellReference), "")
        XCTAssertEqual(aGRExpression.calculatedValue, 6)
        XCTAssertEqual(aGRExpression.stringValue, justACellReference)
    }
    
    func testGRRelativeCellParsing() {
        let aGRRelativeCell = GRRelativeCell()
        
        let validRelativeCell = "r-3c2"
        XCTAssertEqual(aGRRelativeCell.parse(input: validRelativeCell), "")
        XCTAssertNil(aGRRelativeCell.calculatedValue)
        XCTAssertEqual(aGRRelativeCell.stringValue, validRelativeCell)
        XCTAssertEqual(aGRRelativeCell.cellReference, CellReference(row: -3, column: 2))
        
        let invalidRelativeCell = "R3c2"
        XCTAssertNil(aGRRelativeCell.parse(input: invalidRelativeCell))
        XCTAssertNil(aGRRelativeCell.stringValue)
        XCTAssertNil(aGRRelativeCell.cellReference)
        XCTAssertNil(aGRRelativeCell.calculatedValue)
    }
    
    func testGRAbsoluteCellParsing() {
        let aGRAbsoluteCell = GRAbsoluteCell()
        
        let validAbsCell = "ZAAZB123 := 12"
        XCTAssertEqual(aGRAbsoluteCell.parse(input: validAbsCell), " := 12")
        XCTAssertNil(aGRAbsoluteCell.calculatedValue)
        XCTAssertEqual(aGRAbsoluteCell.stringValue, "ZAAZB123")
        XCTAssertEqual(aGRAbsoluteCell.cellReference, CellReference(columnRef: "ZAAZB", rowNumber: 123))
        
        let invalidAbsCell = "ABa12"
        XCTAssertNil(aGRAbsoluteCell.parse(input: invalidAbsCell))
        XCTAssertNil(aGRAbsoluteCell.calculatedValue)
        XCTAssertNil(aGRAbsoluteCell.stringValue)
        XCTAssertNil(aGRAbsoluteCell.cellReference)
    }
    
    func testGRCellReferenceParsing() {
        let aGRCellReference = GRCellReference()
        
        let validRelativeCell = "r40c91"
        XCTAssertEqual(aGRCellReference.parse(input: validRelativeCell), "")
        XCTAssertNil(aGRCellReference.calculatedValue)
        XCTAssertEqual(aGRCellReference.stringValue, validRelativeCell)
        XCTAssertEqual(aGRCellReference.cellReference, CellReference(row: 40, column: 91))
        
        let invalidRelativeCell = "90"
        XCTAssertNil(aGRCellReference.parse(input: invalidRelativeCell))
        XCTAssertNil(aGRCellReference.stringValue)
        XCTAssertNil(aGRCellReference.calculatedValue)
        XCTAssertNil(aGRCellReference.cellReference)
        
        let validAbsCell = "ZAAZB123 := 12"
        XCTAssertEqual(aGRCellReference.parse(input: validAbsCell), " := 12")
        XCTAssertNil(aGRCellReference.calculatedValue)
        XCTAssertEqual(aGRCellReference.stringValue, "ZAAZB123")
        XCTAssertEqual(aGRCellReference.cellReference, CellReference(columnRef: "ZAAZB", rowNumber: 123))
        
        let invalidAbsCell = "a1"
        XCTAssertNil(aGRCellReference.parse(input: invalidAbsCell))
        XCTAssertNil(aGRCellReference.calculatedValue)
        XCTAssertNil(aGRCellReference.stringValue)
        XCTAssertNil(aGRCellReference.cellReference)
    }
    
    func testGRValueParsing() {
        let aGRValue = GRValue()
        
        // Parsing "r1c26+" should consume "r1c26" and leave "+". 
        // The calculated value should be the value in that cell stored in the model.
        let relativeCellRef1 = "r0c26+"
        GrammarRule.cells.add(CellReference(columnRef: "AA", rowNumber: 1), CellContents(expression: "50+1*2", value: 52))
        XCTAssertEqual(aGRValue.parse(input: relativeCellRef1), "+")
        XCTAssertEqual(aGRValue.calculatedValue, 52)
        XCTAssertEqual(aGRValue.stringValue, "r0c26")
        
        // Parsing "r1c25" should consume "r1c25" and leave ""
        // The calculated value should be zero because there is nothing in cell r1c25 (Z1)
        let relativeCellRef2 = "r1c25"
        XCTAssertEqual(aGRValue.parse(input: relativeCellRef2), "")
        XCTAssertEqual(aGRValue.calculatedValue, 0)
        XCTAssertEqual(aGRValue.stringValue, relativeCellRef2)
        
        // Parsing "Z1" should consume "Z1" and leave ""
        // The calculated value should be 53 because there has now been a cell added at Z1 (r1c25)
        let relativeCellRef3 = "Z1"
        GrammarRule.cells.add(CellReference(row: 0, column: 25), CellContents(expression: "50+1+2", value: 53))
        XCTAssertEqual(aGRValue.parse(input: relativeCellRef3), "")
        XCTAssertEqual(aGRValue.calculatedValue, 53)
        XCTAssertEqual(aGRValue.stringValue, relativeCellRef3)
        
        // Parsing "2gd6" should consume and record the "2", and leave the "*2gd6"
        XCTAssertEqual(aGRValue.parse(input: "2*3gd6"), "*3gd6")
        XCTAssertEqual(aGRValue.calculatedValue!, 2)
        XCTAssertEqual(aGRValue.stringValue, "2")
        
        // Parsing "-26" should consume and record the "-26", and leave ""
        XCTAssertEqual(aGRValue.parse(input: "-26"), "")
        XCTAssertEqual(aGRValue.calculatedValue!, -26)
        XCTAssertEqual(aGRValue.stringValue, "-26")
    }
    
    func testGRAssignment() {
        let A2 = CellReference(columnRef: "A", rowNumber: 2)
        let A3 = CellReference(columnRef: "A", rowNumber: 3)
        let assignment = GRAssignment()
        
        let A2equals5 = "A2 := 5"
        
        XCTAssertEqual(assignment.parse(input: A2equals5), "")
        XCTAssertEqual(GrammarRule.cells.get(A2).expression, "5")
        XCTAssertEqual(GrammarRule.cells.get(A2).value, 5)
        
        let A2equalsHello = "A2 := \" hello\""
        
        XCTAssertEqual(assignment.parse(input: A2equalsHello), "")
        XCTAssertEqual(GrammarRule.cells.get(A2).expression, "\" hello\"")
        XCTAssertEqual(GrammarRule.cells.get(A2).value, 0)
        
        let A2equalsTimes = "A2 := 40*2+2*4hello"
        
        XCTAssertEqual(assignment.parse(input: A2equalsTimes), "hello")
        XCTAssertEqual(GrammarRule.cells.get(A2).expression, "40*2+2*4")
        XCTAssertEqual(GrammarRule.cells.get(A2).value, 88)
        
        let A3equalsA2 = "A3 := A2+A2"
        XCTAssertEqual(assignment.parse(input: A3equalsA2), "")
        XCTAssertEqual(GrammarRule.cells.get(A3).expression, "A2+A2")
        XCTAssertEqual(GrammarRule.cells.get(A3).value, 176)
        
        
        let invalidExpression1 = "A3 := +40*2+2*4hello"
        
        XCTAssertNil(assignment.parse(input: invalidExpression1))
        
        let invalidExpression2 = "r3c0 := +40*2+2*4hello"
        
        XCTAssertNil(assignment.parse(input: invalidExpression2))
    }
    
    func testGRPrint() {
        let assignment = GRAssignment()
        
        let print = GRPrint()
        
        XCTAssertEqual(assignment.parse(input: "Z1 := 4*5+1"), "")
        XCTAssertEqual(assignment.parse(input: "Z2 := 20"), "")
        XCTAssertEqual(assignment.parse(input: "Z3 := r0c25+Z2"), "")
        
        XCTAssertEqual(print.parse(input: "print_expr \" hello\""), "")
        XCTAssertEqual(print.parse(input: "print_value \" hello\""), "")
        
        XCTAssertEqual(print.parse(input: "print_expr Z3"), "")
        XCTAssertEqual(print.parse(input: "print_value Z3"), "")
        
        XCTAssertEqual(print.parse(input: "print_expr 6*7+2"), "")
        XCTAssertEqual(print.parse(input: "print_value 6*7+2"), "")
    }
}
