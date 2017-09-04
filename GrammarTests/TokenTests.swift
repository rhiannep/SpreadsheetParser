//
//  TokenTests.swift
//  SpreadsheetParser
//
//  Created by Rhianne Price on 3/09/17.
//  Copyright © 2017 Rhianne Price. All rights reserved.
//
// Tests for the trminal grammar rules.
//

import XCTest

@testable import SpreadsheetParser

class TokenTests: XCTestCase {

    /* Test parsing for the rule Integer -> Postive and negative integers */
    
    // Parsing "2gd6" should consume and record the "2", and leave the "gd6"
    func testGRIntegerParsing1() {
        let aGRInteger = GRInteger()
        
        
        XCTAssertEqual(aGRInteger.parse(input: "2gd6"), "gd6")
        XCTAssertEqual(aGRInteger.calculatedValue.get()!, 2)
        XCTAssertEqual(aGRInteger.stringValue, "2")
    }
    
    // Parsing "-26" should consume and record the "-26", and leave nothing
    func testGRIntegerParsing2() {
        let aGRInteger = GRInteger()
        XCTAssertEqual(aGRInteger.parse(input: "-26"), "")
        XCTAssertEqual(aGRInteger.calculatedValue.get()!, -26)
        XCTAssertEqual(aGRInteger.stringValue, "-26")
    }
    
    // Parsing "NaN" should consume nothing, and leave nothing
    func testGRIntegerParsing3() {
        let aGRInteger = GRInteger()
    
        XCTAssertNil(aGRInteger.parse(input: "NaN"))
        XCTAssertNil(aGRInteger.calculatedValue.get())
        XCTAssertNil(aGRInteger.stringValue)
    }
    
    /* Test parsing for the rule PositiveInteger -> Integers greater than zero */
    
    // Parsing "-2asjd7f7" should consume nothing, and leave nothing
    func testGRPositiveIntegerParsing1() {
        let aGRPositiveInteger = GRPositiveInteger()
    
        XCTAssertNil(aGRPositiveInteger.parse(input: "-2asjd7f7"))
        XCTAssertNil(aGRPositiveInteger.calculatedValue.get())
        XCTAssertNil(aGRPositiveInteger.stringValue)
    }
    
    // Parsing "2gd6" should consume and record the "2", and leave the "gd6"
    func testGRPositiveIntegerParsing() {
        let aGRPositiveInteger = GRPositiveInteger()
        
        XCTAssertEqual(aGRPositiveInteger.parse(input: "2gd6"), "gd6")
        XCTAssertEqual(aGRPositiveInteger.calculatedValue.get()!, 2)
        XCTAssertEqual(aGRPositiveInteger.stringValue, "2")
    }
    
    /* Test parsing for literals */
    
    
    // Parsing "b*a" by literal "b" should consume and record the "b", and leave the "*a"
    func testGRLiteralParsing1() {
        let b = GRLiteral(literal: "b")
        
        XCTAssertEqual(b.parse(input: "b*a"), "*a")
        XCTAssertNil(b.calculatedValue.get())
        XCTAssertEqual(b.stringValue, "b")
    }
    
    // Parsing "hey" by literal "b" should consume nothing, and leave nothing
    func testGRLiteralParsing2() {
        let b = GRLiteral(literal: "b")
        
        XCTAssertNil(b.parse(input: "hey"))
        XCTAssertNil(b.calculatedValue.get())
        XCTAssertNil(b.stringValue)
    }
    
    func testGRLiteralParsing3() {
        let quoteMark = GRLiteral(literal: "\"")
        
        // Parsing "" oh how fast" should consume and record the """, and leave the " oh how fast"
        XCTAssertEqual(quoteMark.parse(input: "\" oh how fast"), " oh how fast")
        XCTAssertNil(quoteMark.calculatedValue.get())
        XCTAssertEqual(quoteMark.stringValue, "\"")
    }
    
    /* Test parsing for the rule UpperAlphaString -> Astring containing only upper case letters */
    
    func testGRUpperAlphaStringParsing1() {
        let aGRUpperAlphaString = GRUpperAlphaString()
        
        // Parsing "BDahs" should consume and record the "BD", and leave the "ahs"
        XCTAssertEqual(aGRUpperAlphaString.parse(input: "BDahs"), "ahs")
        XCTAssertNil(aGRUpperAlphaString.calculatedValue.get())
        XCTAssertEqual(aGRUpperAlphaString.stringValue, "BD")
    }
    
    // Parsing "BD CC" should consume and record the "BD", and leave the " CC"
    func testGRUpperAlphaStringParsing2() {
        let aGRUpperAlphaString = GRUpperAlphaString()
    
        XCTAssertEqual(aGRUpperAlphaString.parse(input: "BD CC"), " CC")
        XCTAssertNil(aGRUpperAlphaString.calculatedValue.get())
        XCTAssertEqual(aGRUpperAlphaString.stringValue, "BD")
    }
    
    // Parsing "23" should fail
    func testGRUpperAlphaStringParsing3() {
        let aGRUpperAlphaString = GRUpperAlphaString()
        
        XCTAssertNil(aGRUpperAlphaString.parse(input: "23"))
        XCTAssertNil(aGRUpperAlphaString.calculatedValue.get())
        XCTAssertNil(aGRUpperAlphaString.stringValue)
    }

}
