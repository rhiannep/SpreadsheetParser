//
//  GrammarTests.swift
//  GrammarTests
//
//  Created by Rhianne Price on 11/08/17.
//  Copyright © 2017 Rhianne Price. All rights reserved.
//
// Tests for the bulk of the grammar rules. Test cases are documented individually.
//

import XCTest

@testable import SpreadsheetParser

class GrammarTests: XCTestCase {
    
    // Parsing ""hello hello" should consume nothing, and leave nothing
    func testGRStringNoQuoteParsing1() {
        let aGRStringNoQuote = GRStringNoQuote()
        
        let hasAQuote = "\" hello hello"
        XCTAssertNil(aGRStringNoQuote.parse(input: hasAQuote))
        XCTAssertNil(aGRStringNoQuote.calculatedValue.get())
        XCTAssertNil(aGRStringNoQuote.stringValue)
    }
    
    // Parsing " hello 25 hello  " should consume and record the " hello 25 hello  ", and leave the empty string
    func testGRStringNoQuoteParsing2() {
        let aGRStringNoQuote = GRStringNoQuote()
        
        let noQuote = " hello 25 hello  "
        XCTAssertEqual(aGRStringNoQuote.parse(input: noQuote), "")
        XCTAssertNil(aGRStringNoQuote.calculatedValue.get())
        XCTAssertEqual(aGRStringNoQuote.stringValue, noQuote)
    }
    
    // Parsing "" hello hello  " 20" should consume and record the "" hello hello  "", and leave " 20"
    func testGRQuotedStringParsing1() {
        let aGRQuotedString = GRQuotedString()
        
        let aStringWithQuotes = "\" hello hello  \" 20"
        XCTAssertEqual(aGRQuotedString.parse(input: aStringWithQuotes), " 20")
        XCTAssertNil(aGRQuotedString.calculatedValue.get())
        XCTAssertEqual(aGRQuotedString.stringValue, "\" hello hello  \"")
    }
    
    // Parsing ""hello hello" should consume nothing, and leave nothing
    func testGRQuotedStringParsing2() {
        let aGRQuotedString = GRQuotedString()
    
        let hasAQuote = "\" hello hello"
        XCTAssertNil(aGRQuotedString.parse(input: hasAQuote))
        XCTAssertNil(aGRQuotedString.calculatedValue.get())
        XCTAssertNil(aGRQuotedString.stringValue)
    }
    
    // Parsing " hello 25 hello  " should consume nothing, and leave nothing
    func testGRQuotedStringParsing3() {
        let aGRQuotedString = GRQuotedString()
        
        let noQuote = " hello 25 hello  "
        XCTAssertNil(aGRQuotedString.parse(input: noQuote))
        XCTAssertNil(aGRQuotedString.calculatedValue.get())
        XCTAssertNil(aGRQuotedString.stringValue)
    }
    
    // Parsing "AB20" should consume and record the "AB", and leave the "20"
    func testGRColumnLabelParsing1() {
        let aGRColumnLabel = GRColumnLabel()
        
        let validLabel = "AB20"
        XCTAssertEqual(aGRColumnLabel.parse(input: validLabel), "20")
        XCTAssertNil(aGRColumnLabel.calculatedValue.get())
        XCTAssertEqual(aGRColumnLabel.stringValue, "AB")
    }
    
    // Parsing "zz20" should consume nothing, and leave nothing
    func testGRColumnLabelParsing2() {
        let aGRColumnLabel = GRColumnLabel()
        
        let invalidLabel = "zz20"
        XCTAssertNil(aGRColumnLabel.parse(input: invalidLabel))
        XCTAssertNil(aGRColumnLabel.calculatedValue.get())
        XCTAssertNil(aGRColumnLabel.stringValue)
    }
    
    // Parsing "20000-" should consume and record the "20000", and leave the empty string
    // Calculated value should be 20000
    func testGRRowNumberParsing1() {
        let aGRRowNumber = GRRowNumber()
        
        let validRowNumber = "20000-"
        XCTAssertEqual(aGRRowNumber.parse(input: validRowNumber), "-")
        XCTAssertEqual(aGRRowNumber.stringValue, "20000")
    }
    
    // Parsing "-2000" should consume nothing, and leave nothing
    func testGRRowNumberParsing2() {
        let aGRRowNumber = GRRowNumber()
        let invalidRowNumber1 = "-2000"
        XCTAssertNil(aGRRowNumber.parse(input: invalidRowNumber1))
        XCTAssertNil(aGRRowNumber.calculatedValue.get())
        XCTAssertNil(aGRRowNumber.stringValue)
    }
    
    // Parsing "NaN" should consume nothing, and leave nothing
    func testGRRowNumberParsing3() {
        let aGRRowNumber = GRRowNumber()
        
        let invalidRowNumber2 = "NaN"
        XCTAssertNil(aGRRowNumber.parse(input: invalidRowNumber2))
        XCTAssertNil(aGRRowNumber.calculatedValue.get())
        XCTAssertNil(aGRRowNumber.stringValue)
    }
    
    // Parsing "*3" should consume and record the "*3", and leave the empty string
    // Calculated value should be 3
    func testProductTermTailParsing1() {
        let aGRproductTermTail = GRProductTermTail()
        
        let times3 = "*3"
        XCTAssertEqual(aGRproductTermTail.parse(input: times3), "")
        XCTAssertEqual(aGRproductTermTail.calculatedValue.get(), 3)
        XCTAssertEqual(aGRproductTermTail.stringValue, times3)
    }
    
    // Parsing "*3*3*4*2+7" should consume and record the "*3*3*4*2", and leave "+7"
    // Calculated value should be 3*3*4*2 = 72
    func testProductTermTailParsing2() {
        let aGRproductTermTail = GRProductTermTail()
        
        let timesTwice = "*-3*3*4*2+7"
        XCTAssertEqual(aGRproductTermTail.parse(input: timesTwice), "+7")
        XCTAssertEqual(aGRproductTermTail.calculatedValue.get(), -72)
        XCTAssertEqual(aGRproductTermTail.stringValue, "*-3*3*4*2")
    }
    
    // Parsing "+7" should consume nothing, and leave nothing
    func testProductTermTailParsing3() {
        let aGRproductTermTail = GRProductTermTail()
    
        
        let plus7 = "+7"
        XCTAssertEqual(aGRproductTermTail.parse(input: plus7), "+7")
        XCTAssertNil(aGRproductTermTail.calculatedValue.get())
        XCTAssertNil(aGRproductTermTail.stringValue)
    }
    
    // With Z1 on the model, Parsing "*5*Z1" should consume and record the "*5*Z1", and leave the empty string
    // With the value in Z1 being 6, calculated value should be 5*6 = 30
    func testProductTermTailParsing4() {
        let aGRproductTermTail = GRProductTermTail()
        
        Spreadsheet.theSpreadsheet.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "2*3", value: CellValue(6)))
        
        let timesCellRef1 = "*5*Z1"
        XCTAssertEqual(aGRproductTermTail.parse(input: timesCellRef1), "")
        XCTAssertEqual(aGRproductTermTail.calculatedValue.get(), 30)
        XCTAssertEqual(aGRproductTermTail.stringValue, timesCellRef1)
    }
    
    // Parsing "*5*Z2" should consume and record the "*5*Z2", and leave the empty string
    // With Z2 not on the model, calculated value should be 5*0 = 0
    func testProductTermTailParsing5() {
        let aGRproductTermTail = GRProductTermTail()
        
        let timesCellRef2 = "*5*Z2"
        XCTAssertEqual(aGRproductTermTail.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRproductTermTail.calculatedValue.get(), 0)
        XCTAssertEqual(aGRproductTermTail.stringValue, timesCellRef2)
    }
    
    // Parsing "3" should consume and record the "3", and leave the empty string
    // Calculated value should be 3
    func testProductTermParsing1() {
        let aGRproductTerm = GRProductTerm()

        let num = "3"
        XCTAssertEqual(aGRproductTerm.parse(input: num), "")
        XCTAssertEqual(aGRproductTerm.calculatedValue.get(), 3)
        XCTAssertEqual(aGRproductTerm.stringValue, num)
    }
    
    // Parsing "3*3*4*2+7" should consume and record the "3*3*4*2", and leave "+7"
    // Calculated value should be 3*3*4*2 = 72
    func testProductTermParsing2() {
        let aGRproductTerm = GRProductTerm()
        
        let timesTwice = "3*3*4*2+7"
        XCTAssertEqual(aGRproductTerm.parse(input: timesTwice), "+7")
        XCTAssertEqual(aGRproductTerm.calculatedValue.get(), 72)
        XCTAssertEqual(aGRproductTerm.stringValue, "3*3*4*2")
    }
    
    // Parsing "*7" should consume nothing, and leave nothing
    func testProductTermParsing3() {
        let aGRproductTerm = GRProductTerm()

        let times7 = "*7"
        XCTAssertNil(aGRproductTerm.parse(input: times7))
        XCTAssertNil(aGRproductTerm.calculatedValue.get())
        XCTAssertNil(aGRproductTerm.stringValue)
    }
    
    // Parsing "5*Z1*10" should consume and record the "5*Z1*10", and leave the empty string
    // With the value in Z1/r1c25 being 6, calculated value should be 5*6*10 = 300
    func testProductTermParsing4() {
        let aGRproductTerm = GRProductTerm()
        let cellValue = CellValue(6)

        Spreadsheet.theSpreadsheet.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "2*3", value: cellValue))
        let timesCellRef1 = "5*Z1*10"
        XCTAssertEqual(aGRproductTerm.parse(input: timesCellRef1), "")
        XCTAssertEqual(aGRproductTerm.calculatedValue.get(), 300)
        XCTAssertEqual(aGRproductTerm.stringValue, timesCellRef1)
    }
    
    // Parsing "5*Z2*10" should consume and record "5*Z2*10", and leave the empty string
    // With Z2/r2c25 not on the model, calculated value should be 5*0*10 = 0
    func testProductTermParsing5() {
        let aGRproductTerm = GRProductTerm()
        
        let timesCellRef2 = "5*Z2*10"
        XCTAssertEqual(aGRproductTerm.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRproductTerm.calculatedValue.get(), 0)
        XCTAssertEqual(aGRproductTerm.stringValue, timesCellRef2)
    }

    
    // Parsing "3" should consume and record the "3", and leave the empty string
    // Calculated value should be 3
    func testExpressionTailParsing1() {
        let aGRExpressionTail = GRExpressionTail()
        
        let plus3 = "+3"
        XCTAssertEqual(aGRExpressionTail.parse(input: plus3), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), 3)
        XCTAssertEqual(aGRExpressionTail.stringValue, plus3)
    }
    
    // Parsing "+-1+2+3+4*7" should consume and record the "+-1+2+3+4*7", and leave the empty string
    // Calculated value should be +-1+2+3+4*7 = 32
    func testExpressionTailParsing2() {
        let aGRExpressionTail = GRExpressionTail()
        
        let plusTwice = "+-1+2+3+4*7"
        XCTAssertEqual(aGRExpressionTail.parse(input: plusTwice), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), 32)
        XCTAssertEqual(aGRExpressionTail.stringValue, plusTwice)
    }
    
    // Parsing "+1*2+3+4*7" should consume "+1*2+3+4*7" and leave the empty string
    // Calculated value should be 1*2+3+4*7 = 33
    func testExpressionTailParsing3() {
        let aGRExpressionTail = GRExpressionTail()
        let plusTwice2 = "+1*2+3+4*7"
        XCTAssertEqual(aGRExpressionTail.parse(input: plusTwice2), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), 33)
        XCTAssertEqual(aGRExpressionTail.stringValue, plusTwice2)
    }
    
    // Parsing "*7" should consume nothing, and leave "*7" (Epsilon parse)
    func testExpressionTailParsing4() {
        let aGRExpressionTail = GRExpressionTail()
        
        let times7 = "*7"
        XCTAssertEqual(aGRExpressionTail.parse(input: times7), times7)
        XCTAssertNil(aGRExpressionTail.calculatedValue.get())
        XCTAssertNil(aGRExpressionTail.stringValue)
    }
    
    // With Z1 := 1*6 = 6 on the model, parsing "+-5*Z1" should record the calculated value as -30
    func testExpressionTailParsing5() {
        let aGRExpressionTail = GRExpressionTail()
        
        // Z1 = 1*6 = 6
        Spreadsheet.theSpreadsheet.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "1*6", value: CellValue(6)))
        
        let timesCellRef1 = "+-5*Z1"
        XCTAssertEqual(aGRExpressionTail.parse(input: timesCellRef1), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), -30)
        XCTAssertEqual(aGRExpressionTail.stringValue, timesCellRef1)
    }
    
    // With AA1 := 1*-2+0 = -2 on the model, parsing "+5*C1+8*AA1" should record the calculated value as 8*AA1 = -16
    func testExpressionTailParsing6() {
        let aGRExpressionTail = GRExpressionTail()
        
        // AA1 = -2
        Spreadsheet.theSpreadsheet.add(CellReference(colLabel: "AA", rowLabel: 1), CellContents(expression: "1*-2+0", value: CellValue(-2)))
        
        let timesCellRef2 = "+5*C1+8*AA1"
        XCTAssertEqual(aGRExpressionTail.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), -16)
        XCTAssertEqual(aGRExpressionTail.stringValue, timesCellRef2)
    }
    
    // Parsing "-3" should consume and record "-3" and leave the empty string
    func testExpressionParsing1() {
        let aGRExpression = GRExpression()
        let three = "3"
        
        XCTAssertEqual(aGRExpression.parse(input: three), "")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 3)
        XCTAssertEqual(aGRExpression.stringValue, three)
    }
    
    // Parsing "1+2+3+-4*7" should consume "1+2+3+-4*7" and leave the empty string
    // Calculated value should be 1+2+3-4*7 = 22
    func testExpressionParsing2() {
        let aGRExpression = GRExpression()
        
        let longExpression1 = "1+2+3+-4*7"
        XCTAssertEqual(aGRExpression.parse(input: longExpression1), "")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), -22)
        XCTAssertEqual(aGRExpression.stringValue, longExpression1)
    }
    
    // Parsing "1+2*3+4*7hello" should consume "1+2*3+4*7" and leave "hello"
    // Calculated value should be 1+2*3+4*7 = 35
    func testExpressionParsing3() {
        let aGRExpression = GRExpression()
        
        let longExpression2 = "1+2*3+4*7hello"
        XCTAssertEqual(aGRExpression.parse(input: longExpression2), "hello")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 35)
        XCTAssertEqual(aGRExpression.stringValue, "1+2*3+4*7")
    }
    
    // Parsing "+7" should consume nothing, and leave nothing
    func testExpressionParsing4() {
        let aGRExpression = GRExpression()
        let plus7 = "+7"
        XCTAssertNil(aGRExpression.parse(input: plus7))
        XCTAssertNil(aGRExpression.calculatedValue.get())
        XCTAssertNil(aGRExpression.stringValue)
    }
    
    // A quoted string can also be and expression
    // Parsing "\"  **any old string\"" should consume "\"  **any old string\"" and leave the empty string
    // calculated value string should be "\"  **any old string\""
    func testExpressionParsing5() {
        let aGRExpression = GRExpression()
        
        let aStringWithQuotes = "\"  **any old string\""
        XCTAssertEqual(aGRExpression.parse(input: aStringWithQuotes), "")
        XCTAssertEqual(aGRExpression.calculatedValue.describing(), aStringWithQuotes)
        XCTAssertEqual(aGRExpression.stringValue, aStringWithQuotes)
    }
    
    // Parsing "  **any old string" should fail because there are no quotes around it
    func testExpressionParsing6() {
        let aGRExpression = GRExpression()
        
        let aStringWithNoQuotes = "  **any old string"
        XCTAssertNil(aGRExpression.parse(input: aStringWithNoQuotes))
        XCTAssertNil(aGRExpression.calculatedValue.get())
        XCTAssertNil(aGRExpression.stringValue)
    }
    
    // With Z1 := 2*3 = 6 on the model, parsing "5*Z1+" should record the calculated value as 30
    func testExpressionParsing7() {
        let aGRExpression = GRExpression()
    
        // Z1 = 6
        Spreadsheet.theSpreadsheet.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "2*3", value: CellValue(6)))
    
        let timesCellRef1 = "5*Z1+"
        XCTAssertEqual(aGRExpression.parse(input: timesCellRef1), "+")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 30)
        XCTAssertEqual(aGRExpression.stringValue, "5*Z1")
    }
    
    // With Z1 := 2*3 = 6 on the model, parsing "Z1" should record the calculated value as 6
    func testExpressionParsing8() {
        let aGRExpression = GRExpression()
        
        // Z1 = 6
        Spreadsheet.theSpreadsheet.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "2*3", value: CellValue(6)))
        let justACellReference = "Z1"
        XCTAssertEqual(aGRExpression.parse(input: justACellReference), "")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 6)
        XCTAssertEqual(aGRExpression.stringValue, justACellReference)
    }
    
    // Parsing a valid relative cell reference with no containing cell should fail
    func testGRRelativeCellParsing1() {
        let aGRRelativeCell = GRRelativeCell()
        
        let validRelativeCell = "r-3c2"
        
        // With no current cell context
        XCTAssertNil(aGRRelativeCell.parse(input: validRelativeCell))
        XCTAssertNil(aGRRelativeCell.calculatedValue.get())
        XCTAssertNil(aGRRelativeCell.stringValue)
        XCTAssertNil(aGRRelativeCell.cellReference)
    }
    
    // Parsing a valid relative cell reference when the context is set should consume and record the "r-3c2"
    // with the containing cell D12 r-3c2 should resolve to F9
    func testGRRelativeCellParsing2() {
        let aGRRelativeCell = GRRelativeCell()
        
        let validRelativeCell = "r-3c2"
        // With a current context
        aGRRelativeCell.set(context: CellReference(colLabel: "D", rowLabel: 12))
        
        XCTAssertEqual(aGRRelativeCell.parse(input: validRelativeCell), "")
        XCTAssertNil(aGRRelativeCell.calculatedValue.get())
        XCTAssertEqual(aGRRelativeCell.stringValue, validRelativeCell)
        XCTAssertEqual(aGRRelativeCell.cellReference, CellReference(colLabel: "F", rowLabel: 9))
    }
    
    // Parsing a valid relative cell that puts the reference out of bounds should fail
    // with the containing cell D12 r-100c-100 should be an invalid cell reference and parsing returns nil
    func testGRRelativeCellParsing3() {
        let aGRRelativeCell = GRRelativeCell()
        aGRRelativeCell.set(context: CellReference(colLabel: "D", rowLabel: 12))

        // valid relative cell that puts reference out of bounds
        let invalidRelativeCell = "r-100c-100"
        XCTAssertNil(aGRRelativeCell.parse(input: invalidRelativeCell))
        XCTAssertNil(aGRRelativeCell.stringValue)
        XCTAssertNil(aGRRelativeCell.cellReference)
        XCTAssertNil(aGRRelativeCell.calculatedValue.get())
    }
    
    // A valid relative cell reference should consume and record "ZAAZB123", a new cell reference and no cell value
    func testGRAbsoluteCellParsing() {
        let aGRAbsoluteCell = GRAbsoluteCell()
        
       
        let validAbsCell = "ZAAZB123 := 12"
        XCTAssertEqual(aGRAbsoluteCell.parse(input: validAbsCell), " := 12")
        XCTAssertNil(aGRAbsoluteCell.calculatedValue.get())
        XCTAssertEqual(aGRAbsoluteCell.stringValue, "ZAAZB123")
        XCTAssertEqual(aGRAbsoluteCell.cellReference, CellReference(colLabel: "ZAAZB", rowLabel: 123))
    }
    
    // Parsing an invalid reference should fail
    func testGRAbsoluteCellParsing2() {
        let aGRAbsoluteCell = GRAbsoluteCell()
        
        let invalidAbsCell1 = "ABa12"
        XCTAssertNil(aGRAbsoluteCell.parse(input: invalidAbsCell1))
        XCTAssertNil(aGRAbsoluteCell.calculatedValue.get())
        XCTAssertNil(aGRAbsoluteCell.stringValue)
        XCTAssertNil(aGRAbsoluteCell.cellReference)
    }
    
    // Parsing an invalid reference should fail
    func testGRAbsoluteCellParsing3() {
        let aGRAbsoluteCell = GRAbsoluteCell()
        
        let invalidAbsCell2 = "A-1"
        XCTAssertNil(aGRAbsoluteCell.parse(input: invalidAbsCell2))
        XCTAssertNil(aGRAbsoluteCell.calculatedValue.get())
        XCTAssertNil(aGRAbsoluteCell.stringValue)
        XCTAssertNil(aGRAbsoluteCell.cellReference)
    }
    
    // Parsing a valid relative cell reference with no containing cell should fail
    func testGRCellReferenceParsing1() {
        let aGRCellReference = GRCellReference()
        let validRelativeCell = "r40c10"
        
        // With no current cell context
        XCTAssertNil(aGRCellReference.parse(input: validRelativeCell))
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertNil(aGRCellReference.stringValue)
        XCTAssertNil(aGRCellReference.cellReference)
    }
    
    // Parsing a valid relative cell reference when the context is set should consume and record the "r-3c2"
    // with the containing cell B2 r4c10 should resolve to L42
    func testGRCellReferenceParsing2() {
        let aGRCellReference = GRCellReference()
        
        let validRelativeCell = "r40c10"
        
        // With the containig cell B2
        aGRCellReference.set(context: CellReference(colLabel: "B", rowLabel: 2))
        
        XCTAssertEqual(aGRCellReference.parse(input: validRelativeCell), "")
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertEqual(aGRCellReference.stringValue, validRelativeCell)
        XCTAssertEqual(aGRCellReference.cellReference, CellReference(colLabel: "L", rowLabel: 42))
    }
    
    // Parsing an invalid reference should fail
    func testGRCellReferenceParsing3() {
        let aGRCellReference = GRCellReference()

        let invalidRelativeCell = "90"
        XCTAssertNil(aGRCellReference.parse(input: invalidRelativeCell))
        XCTAssertNil(aGRCellReference.stringValue)
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertNil(aGRCellReference.cellReference)
    }
    
    // A valids cell reference should consume and record "ZAAZB123", a new cell reference and no cell value
    func testGRCellReferenceParsing4() {
        let aGRCellReference = GRCellReference()

        let validAbsCell = "ZAAZB123 := 12"
        XCTAssertEqual(aGRCellReference.parse(input: validAbsCell), " := 12")
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertEqual(aGRCellReference.stringValue, "ZAAZB123")
        XCTAssertEqual(aGRCellReference.cellReference, CellReference(colLabel: "ZAAZB", rowLabel: 123))
    }
    
    // Parsing an invalid reference should fail
    func testGRCellReferenceParsing5() {
        let aGRCellReference = GRCellReference()

        let invalidAbsCell = "a1"
        XCTAssertNil(aGRCellReference.parse(input: invalidAbsCell))
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertNil(aGRCellReference.stringValue)
        XCTAssertNil(aGRCellReference.cellReference)
    }
    
    // Parsing "Z1" should consume "Z1" and leave ""
    // The calculated value should be 53 because there has now been a cell added at Z1
    func testGRValueParsing1() {
        let aGRValue = GRValue()
        let relativeCellRef3 = "Z1"
        
        Spreadsheet.theSpreadsheet.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "50+1+2", value: CellValue(53)))
        
        XCTAssertEqual(aGRValue.parse(input: relativeCellRef3), "")
        XCTAssertEqual(aGRValue.calculatedValue.get(), 53)
        XCTAssertEqual(aGRValue.stringValue, relativeCellRef3)
    }
    
    // Parsing "-26" should consume and record the "-26", and leave ""
    func testGRValueParsing2() {
        let aGRValue = GRValue()
        // Parsing "2gd6" should consume and record the "2", and leave the "*2gd6"
        XCTAssertEqual(aGRValue.parse(input: "2*3gd6"), "*3gd6")
        XCTAssertEqual(aGRValue.calculatedValue.get()!, 2)
        XCTAssertEqual(aGRValue.stringValue, "2")
        
    }
    
    // Parsing "-26" should consume and record the "-26", and leave ""
    func testGRValueParsing3() {
        let aGRValue = GRValue()
       
        XCTAssertEqual(aGRValue.parse(input: "-26"), "")
        XCTAssertEqual(aGRValue.calculatedValue.get()!, -26)
        XCTAssertEqual(aGRValue.stringValue, "-26")
    }
}
