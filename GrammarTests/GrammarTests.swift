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
        Cells.clear()
    }
    
    func testGRIntegerParsing() {
        let aGRInteger = GRInteger()
        
        // Parsing "2gd6" should consume and record the "2", and leave the "gd6"
        XCTAssertEqual(aGRInteger.parse(input: "2gd6"), "gd6")
        XCTAssertEqual(aGRInteger.calculatedValue.get()!, 2)
        XCTAssertEqual(aGRInteger.stringValue, "2")
        
        // Parsing "-26" should consume and record the "-26", and leave nothing
        XCTAssertEqual(aGRInteger.parse(input: "-26"), "")
        XCTAssertEqual(aGRInteger.calculatedValue.get()!, -26)
        XCTAssertEqual(aGRInteger.stringValue, "-26")
        
        // Parsing "NaN" should consume nothing, and leave nothing
        XCTAssertNil(aGRInteger.parse(input: "NaN"))
        XCTAssertNil(aGRInteger.calculatedValue.get())
        XCTAssertNil(aGRInteger.stringValue)
    }
    
    func testGRPositiveIntegerParsing() {
        let aGRPositiveInteger = GRPositiveInteger()
        
        // Parsing "-2asjd7f7" should consume nothing, and leave nothing
        XCTAssertNil(aGRPositiveInteger.parse(input: "-2asjd7f7"))
        XCTAssertNil(aGRPositiveInteger.calculatedValue.get())
        XCTAssertNil(aGRPositiveInteger.stringValue)
        
        // Parsing "2gd6" should consume and record the "2", and leave the "gd6"
        XCTAssertEqual(aGRPositiveInteger.parse(input: "2gd6"), "gd6")
        XCTAssertEqual(aGRPositiveInteger.calculatedValue.get()!, 2)
        XCTAssertEqual(aGRPositiveInteger.stringValue, "2")
    }
    
    func testGRLiteralParsing() {
        // Parsing "b*a" should consume and record the "b", and leave the "*a"
        let b = GRLiteral(literal: "b")
        XCTAssertEqual(b.parse(input: "b*a"), "*a")
        XCTAssertNil(b.calculatedValue.get())
        XCTAssertEqual(b.stringValue, "b")
        
        // Parsing "hey" should consume nothing, and leave nothing
        XCTAssertNil(b.parse(input: "hey"))
        XCTAssertNil(b.calculatedValue.get())
        XCTAssertNil(b.stringValue)
        
        let quoteMark = GRLiteral(literal: "\"")
        
        // Parsing "" oh how fast" should consume and record the """, and leave the " oh how fast"
        XCTAssertEqual(quoteMark.parse(input: "\" oh how fast"), " oh how fast")
        XCTAssertNil(quoteMark.calculatedValue.get())
        XCTAssertEqual(quoteMark.stringValue, "\"")
    }
    
    func testGRUpperAlphaStringParsing() {
        let aGRUpperAlphaString = GRUpperAlphaString()
        
        // Parsing "BDahs" should consume and record the "BD", and leave the "ahs"
        XCTAssertEqual(aGRUpperAlphaString.parse(input: "BDahs"), "ahs")
        XCTAssertNil(aGRUpperAlphaString.calculatedValue.get())
        XCTAssertEqual(aGRUpperAlphaString.stringValue, "BD")
        
        // Parsing "23" should consume nothing, and leave nothing
        XCTAssertNil(aGRUpperAlphaString.parse(input: "23"))
        XCTAssertNil(aGRUpperAlphaString.calculatedValue.get())
        XCTAssertNil(aGRUpperAlphaString.stringValue)
    }
    
    func testGRStringNoQuoteParsing() {
        let aGRStringNoQuote = GRStringNoQuote()
        
        // Parsing ""hello hello" should consume nothing, and leave nothing
        let hasAQuote = "\" hello hello"
        XCTAssertNil(aGRStringNoQuote.parse(input: hasAQuote))
        XCTAssertNil(aGRStringNoQuote.calculatedValue.get())
        XCTAssertNil(aGRStringNoQuote.stringValue)
        
        // Parsing " hello 25 hello  " should consume and record the " hello 25 hello  ", and leave the empty string
        let noQuote = " hello 25 hello  "
        XCTAssertEqual(aGRStringNoQuote.parse(input: noQuote), "")
        XCTAssertNil(aGRStringNoQuote.calculatedValue.get())
        XCTAssertEqual(aGRStringNoQuote.stringValue, noQuote)
    }
    
    func testGRQuotedStringParsing() {
        let aGRQuotedString = GRQuotedString()
        
        // Parsing "" hello hello  " 20" should consume and record the "" hello hello  "", and leave " 20"
        let aStringWithQuotes = "\" hello hello  \" 20"
        XCTAssertEqual(aGRQuotedString.parse(input: aStringWithQuotes), " 20")
        XCTAssertNil(aGRQuotedString.calculatedValue.get())
        XCTAssertEqual(aGRQuotedString.stringValue, "\" hello hello  \"")
        
        // Parsing ""hello hello" should consume nothing, and leave nothing
        let hasAQuote = "\" hello hello"
        XCTAssertNil(aGRQuotedString.parse(input: hasAQuote))
        XCTAssertNil(aGRQuotedString.calculatedValue.get())
        XCTAssertNil(aGRQuotedString.stringValue)
        
        // Parsing " hello 25 hello  " should consume nothing, and leave nothing
        let noQuote = " hello 25 hello  "
        XCTAssertNil(aGRQuotedString.parse(input: noQuote))
        XCTAssertNil(aGRQuotedString.calculatedValue.get())
        XCTAssertNil(aGRQuotedString.stringValue)

    }
    
    func testGRColumnLabelParsing() {
        let aGRColumnLabel = GRColumnLabel()
        
        // Parsing "AB20" should consume and record the "AB", and leave the "20"
        let validLabel = "AB20"
        XCTAssertEqual(aGRColumnLabel.parse(input: validLabel), "20")
        XCTAssertNil(aGRColumnLabel.calculatedValue.get())
        XCTAssertEqual(aGRColumnLabel.stringValue, "AB")
        
        // Parsing "zz20" should consume nothing, and leave nothing
        let invalidLabel = "zz20"
        XCTAssertNil(aGRColumnLabel.parse(input: invalidLabel))
        XCTAssertNil(aGRColumnLabel.calculatedValue.get())
        XCTAssertNil(aGRColumnLabel.stringValue)
    }
    
    func testGRRowNumberParsing() {
        let aGRRowNumber = GRRowNumber()
        
        // Parsing "20000-" should consume and record the "20000", and leave the empty string
        // Calculated value should be 20000
        let validRowNumber = "20000-"
        XCTAssertEqual(aGRRowNumber.parse(input: validRowNumber), "-")
        XCTAssertEqual(aGRRowNumber.calculatedValue.get(), 20000)
        XCTAssertEqual(aGRRowNumber.stringValue, "20000")
        
        // Parsing "-2000" should consume nothing, and leave nothing
        let invalidRowNumber1 = "-2000"
        XCTAssertNil(aGRRowNumber.parse(input: invalidRowNumber1))
        XCTAssertNil(aGRRowNumber.calculatedValue.get())
        XCTAssertNil(aGRRowNumber.stringValue)
        
        // Parsing "NaN" should consume nothing, and leave nothing
        let invalidRowNumber2 = "NaN"
        XCTAssertNil(aGRRowNumber.parse(input: invalidRowNumber2))
        XCTAssertNil(aGRRowNumber.calculatedValue.get())
        XCTAssertNil(aGRRowNumber.stringValue)
    }
    
    func testProductTermTailParsing() {
        let aGRproductTermTail = GRProductTermTail()
        let cellValue = CellValue()
        cellValue.set(number: 6)
        
        // Parsing "*3" should consume and record the "*3", and leave the empty string
        // Calculated value should be 3
        let times3 = "*3"
        XCTAssertEqual(aGRproductTermTail.parse(input: times3), "")
        XCTAssertEqual(aGRproductTermTail.calculatedValue.get(), 3)
        XCTAssertEqual(aGRproductTermTail.stringValue, times3)
        
        // Parsing "*3*3*4*2+7" should consume and record the "*3*3*4*2", and leave "+7"
        // Calculated value should be 3*3*4*2 = 72
        let timesTwice = "*-3*3*4*2+7"
        XCTAssertEqual(aGRproductTermTail.parse(input: timesTwice), "+7")
        XCTAssertEqual(aGRproductTermTail.calculatedValue.get(), -72)
        XCTAssertEqual(aGRproductTermTail.stringValue, "*-3*3*4*2")
        
        // Parsing "+7" should consume nothing, and leave nothing
        let plus7 = "+7"
        XCTAssertEqual(aGRproductTermTail.parse(input: plus7), "+7")
        XCTAssertNil(aGRproductTermTail.calculatedValue.get())
        XCTAssertNil(aGRproductTermTail.stringValue)
        
        // With Z1/r1c25 on the model, Parsing "*5*Z1" should consume and record the "*5*Z1", and leave the empty string
        // With the value in Z1 being 6, calculated value should be 5*6 = 30
        Cells.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "2*3", value: cellValue))
        let timesCellRef1 = "*5*Z1"
        XCTAssertEqual(aGRproductTermTail.parse(input: timesCellRef1), "")
        XCTAssertEqual(aGRproductTermTail.calculatedValue.get(), 30)
        XCTAssertEqual(aGRproductTermTail.stringValue, timesCellRef1)
        
        // Parsing "*5*Z2" should consume and record the "*5*Z2", and leave the empty string
        // With Z2/r2c25 not on the model, calculated value should be 5*0 = 0
        let timesCellRef2 = "*5*Z2"
        XCTAssertEqual(aGRproductTermTail.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRproductTermTail.calculatedValue.get(), 0)
        XCTAssertEqual(aGRproductTermTail.stringValue, timesCellRef2)
    }
    
    func testProductTermParsing() {
        let aGRproductTerm = GRProductTerm()
        let cellValue = CellValue()
        cellValue.set(number: 6)
        
        // Parsing "3" should consume and record the "3", and leave the empty string
        // Calculated value should be 3
        let num = "3"
        XCTAssertEqual(aGRproductTerm.parse(input: num), "")
        XCTAssertEqual(aGRproductTerm.calculatedValue.get(), 3)
        XCTAssertEqual(aGRproductTerm.stringValue, num)
        
        // Parsing "3*3*4*2+7" should consume and record the "3*3*4*2", and leave "+7"
        // Calculated value should be 3*3*4*2 = 72
        let timesTwice = "3*3*4*2+7"
        XCTAssertEqual(aGRproductTerm.parse(input: timesTwice), "+7")
        XCTAssertEqual(aGRproductTerm.calculatedValue.get(), 72)
        XCTAssertEqual(aGRproductTerm.stringValue, "3*3*4*2")
        
        // Parsing "*7" should consume nothing, and leave nothing
        let times7 = "*7"
        XCTAssertNil(aGRproductTerm.parse(input: times7))
        XCTAssertNil(aGRproductTerm.calculatedValue.get())
        XCTAssertNil(aGRproductTerm.stringValue)
        
        // Parsing "5*Z1*10" should consume and record the "5*Z1*10", and leave the empty string
        // With the value in Z1/r1c25 being 6, calculated value should be 5*6*10 = 300
        Cells.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "2*3", value: cellValue))
        let timesCellRef1 = "5*Z1*10"
        XCTAssertEqual(aGRproductTerm.parse(input: timesCellRef1), "")
        XCTAssertEqual(aGRproductTerm.calculatedValue.get(), 300)
        XCTAssertEqual(aGRproductTerm.stringValue, timesCellRef1)
        
        // Parsing "5*Z2*10" should consume and record "5*Z2*10", and leave the empty string
        // With Z2/r2c25 not on the model, calculated value should be 5*0*10 = 0
        let timesCellRef2 = "5*Z2*10"
        XCTAssertEqual(aGRproductTerm.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRproductTerm.calculatedValue.get(), 0)
        XCTAssertEqual(aGRproductTerm.stringValue, timesCellRef2)
    }
    
    func testExpressionTailParsing() {
        let aGRExpressionTail = GRExpressionTail()
        let cellValue6 = CellValue()
        cellValue6.set(number: 6)
        
        let cellValue2 = CellValue()
        cellValue2.set(number: 2)
        
        // Parsing "3" should consume and record the "3", and leave the empty string
        // Calculated value should be 3
        let plus3 = "+3"
        XCTAssertEqual(aGRExpressionTail.parse(input: plus3), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), 3)
        XCTAssertEqual(aGRExpressionTail.stringValue, plus3)
        
        // Parsing "+1+2+3+4*7" should consume and record the "+1+2+3+4*7", and leave the empty string
        // Calculated value should be 3*3*4*2 = 72
        let plusTwice = "+1+2+3+4*7"
        XCTAssertEqual(aGRExpressionTail.parse(input: plusTwice), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), 34)
        XCTAssertEqual(aGRExpressionTail.stringValue, plusTwice)
        
        let plusTwice2 = "+1*2+3+4*7"
        XCTAssertEqual(aGRExpressionTail.parse(input: plusTwice2), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), 33)
        XCTAssertEqual(aGRExpressionTail.stringValue, plusTwice2)
        
        // Parsing "*7" should consume nothing, and leave "*7" (Epsilon parse)
        let times7 = "*7"
        XCTAssertEqual(aGRExpressionTail.parse(input: times7), times7)
        XCTAssertNil(aGRExpressionTail.calculatedValue.get())
        XCTAssertNil(aGRExpressionTail.stringValue)
        
        Cells.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "2*3", value: cellValue6))
        
        Cells.add(CellReference(colLabel: "AA", rowLabel: 1), CellContents(expression: "2*3", value: cellValue2))
        let timesCellRef1 = "+5*Z1"
        XCTAssertEqual(aGRExpressionTail.parse(input: timesCellRef1), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), 30)
        XCTAssertEqual(aGRExpressionTail.stringValue, timesCellRef1)
        
        let timesCellRef2 = "+5*C1+8*AA1"
        XCTAssertEqual(aGRExpressionTail.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRExpressionTail.calculatedValue.get(), 16)
        XCTAssertEqual(aGRExpressionTail.stringValue, timesCellRef2)
    }
    
    func testExpressionParsing() {
        let aGRExpression = GRExpression()
        let cellValue6 = CellValue(6)
        
        let cellValue2 = CellValue(2)
        
        let three = "3"
        XCTAssertEqual(aGRExpression.parse(input: three), "")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 3)
        XCTAssertEqual(aGRExpression.stringValue, three)
        
        let longExpression1 = "1+2+3+4*7"
        XCTAssertEqual(aGRExpression.parse(input: longExpression1), "")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 34)
        XCTAssertEqual(aGRExpression.stringValue, longExpression1)
        
        let longExpression2 = "1+2*3+4*7hello"
        XCTAssertEqual(aGRExpression.parse(input: longExpression2), "hello")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 35)
        XCTAssertEqual(aGRExpression.stringValue, "1+2*3+4*7")
        
        // Parsing "+7" should consume nothing, and leave nothing
        let plus7 = "+7"
        XCTAssertNil(aGRExpression.parse(input: plus7))
        XCTAssertNil(aGRExpression.calculatedValue.get())
        XCTAssertNil(aGRExpression.stringValue)
        
        let aStringWithQuotes = "\"  **any old string\""
        XCTAssertEqual(aGRExpression.parse(input: aStringWithQuotes), "")
        XCTAssertEqual(aGRExpression.calculatedValue.describing(), aStringWithQuotes)
        XCTAssertEqual(aGRExpression.stringValue, aStringWithQuotes)
        
        let aStringWithNoQuotes = "  **any old string"
        XCTAssertNil(aGRExpression.parse(input: aStringWithNoQuotes))
        XCTAssertNil(aGRExpression.calculatedValue.get())
        XCTAssertNil(aGRExpression.stringValue)
        
        // Z1 = 6
        Cells.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "2*3", value: cellValue6))
        // AA2 = 2
        Cells.add(CellReference(colLabel: "AA", rowLabel: 2), CellContents(expression: "2*3", value: cellValue2))
        
        let timesCellRef1 = "5*Z1+"
        XCTAssertEqual(aGRExpression.parse(input: timesCellRef1), "+")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 30)
        XCTAssertEqual(aGRExpression.stringValue, "5*Z1")
        
        Cells.currentContext = CellReference(colLabel: "Z", rowLabel: 1)
        let timesCellRef2 = "5*Z1*r1c1+8"
        XCTAssertEqual(aGRExpression.parse(input: timesCellRef2), "")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 68)
        XCTAssertEqual(aGRExpression.stringValue, timesCellRef2)
        
        let justACellReference = "Z1"
        XCTAssertEqual(aGRExpression.parse(input: justACellReference), "")
        XCTAssertEqual(aGRExpression.calculatedValue.get(), 6)
        XCTAssertEqual(Cells.get("Z1")?.value.get(), 6)
        XCTAssertEqual(aGRExpression.stringValue, justACellReference)
    }
    
    func testGRRelativeCellParsing() {
        let aGRRelativeCell = GRRelativeCell()
        
        // With a current context but nothing in that cell
        Cells.currentContext = CellReference(colLabel: "AA", rowLabel: 12)
        let validRelativeCell = "r-3c2"
        XCTAssertEqual(aGRRelativeCell.parse(input: validRelativeCell), "")
        XCTAssertNil(aGRRelativeCell.calculatedValue.get())
        XCTAssertEqual(aGRRelativeCell.stringValue, validRelativeCell)
        XCTAssertEqual(aGRRelativeCell.cellReference, CellReference(colLabel: "AC", rowLabel: 9))
        
        // With no current context, parsing should return nil
        Cells.currentContext = nil
        XCTAssertNil(aGRRelativeCell.parse(input: validRelativeCell))
        XCTAssertNil(aGRRelativeCell.calculatedValue.get())
        XCTAssertNil(aGRRelativeCell.stringValue)
        XCTAssertNil(aGRRelativeCell.cellReference)
        
        
        let invalidRelativeCell = "R3c2"
        XCTAssertNil(aGRRelativeCell.parse(input: invalidRelativeCell))
        XCTAssertNil(aGRRelativeCell.stringValue)
        XCTAssertNil(aGRRelativeCell.cellReference)
        XCTAssertNil(aGRRelativeCell.calculatedValue.get())
    }
    
    func testGRAbsoluteCellParsing() {
        let aGRAbsoluteCell = GRAbsoluteCell()
        
        let validAbsCell = "ZAAZB123 := 12"
        XCTAssertEqual(aGRAbsoluteCell.parse(input: validAbsCell), " := 12")
        XCTAssertNil(aGRAbsoluteCell.calculatedValue.get())
        XCTAssertEqual(aGRAbsoluteCell.stringValue, "ZAAZB123")
        XCTAssertEqual(aGRAbsoluteCell.cellReference, CellReference(colLabel: "ZAAZB", rowLabel: 123))
        
        let invalidAbsCell = "ABa12"
        XCTAssertNil(aGRAbsoluteCell.parse(input: invalidAbsCell))
        XCTAssertNil(aGRAbsoluteCell.calculatedValue.get())
        XCTAssertNil(aGRAbsoluteCell.stringValue)
        XCTAssertNil(aGRAbsoluteCell.cellReference)
    }
    
    func testGRCellReferenceParsing() {
        let aGRCellReference = GRCellReference()
        
        // With a current context
        Cells.currentContext = CellReference(colLabel: "A", rowLabel: 1)
        let validRelativeCell = "r40c10"
        XCTAssertEqual(aGRCellReference.parse(input: validRelativeCell), "")
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertEqual(aGRCellReference.stringValue, validRelativeCell)
        XCTAssertEqual(aGRCellReference.cellReference, CellReference(colLabel: "K", rowLabel: 41))
        
        //With no current cell context
        Cells.currentContext = nil
        XCTAssertNil(aGRCellReference.parse(input: validRelativeCell))
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertNil(aGRCellReference.stringValue)
        XCTAssertNil(aGRCellReference.cellReference)
        
        let invalidRelativeCell = "90"
        XCTAssertNil(aGRCellReference.parse(input: invalidRelativeCell))
        XCTAssertNil(aGRCellReference.stringValue)
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertNil(aGRCellReference.cellReference)
        
        let validAbsCell = "ZAAZB123 := 12"
        XCTAssertEqual(aGRCellReference.parse(input: validAbsCell), " := 12")
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertEqual(aGRCellReference.stringValue, "ZAAZB123")
        XCTAssertEqual(aGRCellReference.cellReference, CellReference(colLabel: "ZAAZB", rowLabel: 123))
        
        let invalidAbsCell = "a1"
        XCTAssertNil(aGRCellReference.parse(input: invalidAbsCell))
        XCTAssertNil(aGRCellReference.calculatedValue.get())
        XCTAssertNil(aGRCellReference.stringValue)
        XCTAssertNil(aGRCellReference.cellReference)
    }
    
    func testGRValueParsing() {
        let aGRValue = GRValue()
        let cellValue52 = CellValue()
        cellValue52.set(number: 52)
        
        let cellValue53 = CellValue()
        cellValue53.set(number: 53)
        
        // Parsing "r40c1+" should consume "r40c1" and leave "+".
        // The calculated value should be the value in that cell stored in the model.
        Cells.currentContext = CellReference(colLabel: "Z", rowLabel: 1)
        let relativeCellRef1 = "r40c1+"
        Cells.add(CellReference(colLabel: "AA", rowLabel: 41), CellContents(expression: "50+1*2", value: cellValue52))
        XCTAssertEqual(aGRValue.parse(input: relativeCellRef1), "+")
        XCTAssertEqual(aGRValue.calculatedValue.get(), 52)
        XCTAssertEqual(aGRValue.stringValue, "r40c1")
        
        // Parsing "r1c25" should consume "r1c25" and leave ""
        // The calculated value should be zero because there is nothing in cell r1c25 relative to Z1 (ZZ2)
        let relativeCellRef2 = "r1c25"
        XCTAssertEqual(aGRValue.parse(input: relativeCellRef2), "")
        XCTAssertEqual(aGRValue.calculatedValue.get(), 0)
        XCTAssertEqual(aGRValue.stringValue, relativeCellRef2)
        
        // Parsing "Z1" should consume "Z1" and leave ""
        // The calculated value should be 53 because there has now been a cell added at Z1
        let relativeCellRef3 = "Z1"
        Cells.add(CellReference(colLabel: "Z", rowLabel: 1), CellContents(expression: "50+1+2", value: cellValue53))
        XCTAssertEqual(aGRValue.parse(input: relativeCellRef3), "")
        XCTAssertEqual(aGRValue.calculatedValue.get(), 53)
        XCTAssertEqual(aGRValue.stringValue, relativeCellRef3)
        
        // Parsing "2gd6" should consume and record the "2", and leave the "*2gd6"
        XCTAssertEqual(aGRValue.parse(input: "2*3gd6"), "*3gd6")
        XCTAssertEqual(aGRValue.calculatedValue.get()!, 2)
        XCTAssertEqual(aGRValue.stringValue, "2")
        
        // Parsing "-26" should consume and record the "-26", and leave ""
        XCTAssertEqual(aGRValue.parse(input: "-26"), "")
        XCTAssertEqual(aGRValue.calculatedValue.get()!, -26)
        XCTAssertEqual(aGRValue.stringValue, "-26")
    }
    
    func testGRAssignment() {
        let A1 = CellReference(colLabel: "A", rowLabel: 1)
        let A2 = CellReference(colLabel: "A", rowLabel: 2)
        let A3 = CellReference(colLabel: "A", rowLabel: 3)
        let assignment = GRAssignment()
        
        let A2equals5 = "A2 := 5"
        
        XCTAssertEqual(assignment.parse(input: A2equals5), "")
        XCTAssertEqual(Cells.get(A2).expression, "5")
        XCTAssertEqual(Cells.get(A2).value.get(), 5)
        
        let A2equalsA2 = "A2 := A2 + 1"
        XCTAssertEqual(assignment.parse(input: A2equalsA2), "")
        XCTAssertEqual(Cells.get(A2).expression, "A2+1")
        XCTAssertEqual(Cells.get(A2).value.get(), 6)
        
        let A2equalsHello = "A2 := \" hello\""
        
        XCTAssertEqual(assignment.parse(input: A2equalsHello), "")
        XCTAssertEqual(Cells.get(A2).expression, "\" hello\"")
        XCTAssertEqual(Cells.get(A2).value.describing(), "\" hello\"")
        
        let A2equalsTimes = "A2 := 40*2+2*4hello"
        
        XCTAssertEqual(assignment.parse(input: A2equalsTimes), "hello")
        XCTAssertEqual(Cells.get(A2).expression, "40*2+2*4")
        XCTAssertEqual(Cells.get(A2).value.get(), 88)
        
        let A3equalsA2 = "A3 := A2+A2"
        XCTAssertEqual(assignment.parse(input: A3equalsA2), "")
        XCTAssertEqual(Cells.get(A3).expression, "A2+A2")
        XCTAssertEqual(Cells.get(A3).value.get(), 176)
        
        
        let invalidExpression1 = "A3 := +40*2+2*4hello"
        XCTAssertNil(assignment.parse(input: invalidExpression1))
        
        let invalidExpression2 = "r3c0 := +40*2+2*4hello"
        XCTAssertNil(assignment.parse(input: invalidExpression2))
        
        // Test that assignment expressions are parsed in the correct order.
        let multipleAssignments = "A3 := 3 A2 := A3*2 A3 := A2*2 A2 := A3*2"
        XCTAssertEqual(assignment.parse(input: multipleAssignments), "")
        XCTAssertEqual(Cells.get(A3).expression, "A2*2")
        XCTAssertEqual(Cells.get(A3).value.get(), 12)
        XCTAssertEqual(Cells.get(A2).expression, "A3*2")
        XCTAssertEqual(Cells.get(A2).value.get(), 24)
        
        // Test relative cell assignment
        // A2 := 2
        // A3 := A2*2 = 4
        XCTAssertEqual(assignment.parse(input: "A2 := 2"), "")
        XCTAssertEqual(assignment.parse(input: "A3 := r-1c0*2"), "")
        XCTAssertEqual(Cells.get(A3).expression, "r-1c0*2")
        XCTAssertEqual(Cells.get(A3).value.get(), 4)
        
        // A1 := A3 * 3 = 12
        XCTAssertEqual(assignment.parse(input: "A1 := A3*3"), "")
        XCTAssertEqual(Cells.get(A1).expression, "A3*3")
        XCTAssertEqual(Cells.get(A1).value.get(), 12)
        
        //A3 := A2 * A3 = 4 * 2
        XCTAssertEqual(assignment.parse(input: "A3 := r-1c0*r0c0"), "")
        XCTAssertEqual(Cells.get(A3).expression, "r-1c0*r0c0")
        XCTAssertEqual(Cells.get(A3).value.get(), 8)
        
        XCTAssertNil(assignment.parse(input: "r1c1 := 12"))
        
        
    }
    
    func testGRPrint() {
        let assignment = GRAssignment()
        let print = GRPrint()
        
        // Check console to check that printed output is correct
        
        // Z1 = 21, Z2 = 20, Z3 = Z1+Z2 = 41
        XCTAssertEqual(assignment.parse(input: "Z1 := 4*5+1 Z2 := 20"), "")
        XCTAssertEqual(assignment.parse(input: "Z3 := r-2c0+Z2"), "")
        
        XCTAssertEqual(print.parse(input: "print_expr \" hello\""), "")
        XCTAssertEqual(print.parse(input: "print_value \" hello\""), "")
        
        XCTAssertEqual(print.parse(input: "print_value Z1+Z2 print_expr Z1+Z2"), "")
        
        XCTAssertEqual(print.parse(input: "print_expr Z3 print_value Z3"), "")

        XCTAssertEqual(print.parse(input: "print_expr 6*7+2 print_value 6+7+2"), "")
        
        XCTAssertNil(print.parse(input: "Print_expr 34*2"))
    }
    
    func testGRSpreadsheetParsing() {
        let input = "A1 := \"hello\" print_expr A1"
        let spreadsheet = GRSpreadsheet()
        
        XCTAssertEqual(spreadsheet.parse(input: input), "")
        
    }
}
