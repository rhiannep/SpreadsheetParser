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
    }
    
    func testGRIntegerParsing() {
        var aGRInteger = GRInteger()
        XCTAssert(checkRemainingInput(rule: aGRInteger, input: "2gd6", expectedToRemain: "gd6"))
        XCTAssertEqual(aGRInteger.calculatedValue!, 2)
        
        aGRInteger = GRInteger()
        XCTAssert(checkRecordedString(rule: aGRInteger, input: "-2asjd7f7", expectedToRecord: "-2"))
        XCTAssertEqual(aGRInteger.calculatedValue!, -2)
        
        aGRInteger = GRInteger()
        XCTAssert(checkRemainingInput(rule: aGRInteger, input: "NaN", expectedToRemain: "NaN"))
        XCTAssert(checkRecordedString(rule: aGRInteger, input: "-NaN", expectedToRecord: ""))
    }
    
    func testGRPositiveIntegerParsing() {
        var aGRPositiveInteger = GRPositiveInteger()
        
        XCTAssert(checkRecordedString(rule: aGRPositiveInteger, input: "-2asjd7f7", expectedToRecord: ""))
        XCTAssert(checkRemainingInput(rule: aGRPositiveInteger, input: "-2asjd7f7", expectedToRemain: "-2asjd7f7"))
        XCTAssertEqual(aGRPositiveInteger.calculatedValue, nil)
        
        aGRPositiveInteger = GRPositiveInteger()
        XCTAssert(checkRemainingInput(rule: aGRPositiveInteger, input: "2gd6", expectedToRemain: "gd6"))
        XCTAssertEqual(aGRPositiveInteger.calculatedValue!, 2)
        

        aGRPositiveInteger = GRPositiveInteger()
        XCTAssert(checkRemainingInput(rule: aGRPositiveInteger, input: "NaN", expectedToRemain: "NaN"))
        
        aGRPositiveInteger = GRPositiveInteger()
        XCTAssert(checkRecordedString(rule: aGRPositiveInteger, input: "-NaN", expectedToRecord: ""))
    }
    
    func testGRLiteralParsing() {
        let b = GRLiteral(literal: "b")
        XCTAssert(checkRecordedString(rule: b, input: "-2asjd7f7", expectedToRecord: ""))
        XCTAssert(checkRemainingInput(rule: b, input: "b*a", expectedToRemain: "*a"))
        XCTAssert(checkRecordedString(rule: b, input: "b*a", expectedToRecord: "b"))
        
        let quoteMark = GRLiteral(literal: "\"")
        
        XCTAssert(checkRecordedString(rule: quoteMark, input: "\" oh how fast", expectedToRecord: "\""))
        XCTAssert(checkRemainingInput(rule: quoteMark, input: "\" oh how fast", expectedToRemain: " oh how fast"))
    }
    
    func testGRUpperAlphaStringParsing() {
        var aGRUpperAlphaString = GRUpperAlphaString()
        XCTAssert(checkRecordedString(rule: aGRUpperAlphaString, input: "BDahs", expectedToRecord: "BD"))
        XCTAssert(checkRemainingInput(rule: aGRUpperAlphaString, input: "BDahs", expectedToRemain: "ahs"))
        XCTAssertEqual(aGRUpperAlphaString.calculatedValue, nil)
        
        aGRUpperAlphaString = GRUpperAlphaString()
        XCTAssert(checkRecordedString(rule: aGRUpperAlphaString, input: "23", expectedToRecord: ""))
        XCTAssert(checkRemainingInput(rule: aGRUpperAlphaString, input: "23", expectedToRemain: "23"))
    }
    
    
    

    private func checkRemainingInput(rule : GrammarRule, input: String, expectedToRemain: String) -> Bool {
        if let remaining = rule.parse(input: input) {
            return remaining == expectedToRemain
        }
        if expectedToRemain == input {
            return true
        }
        return false
    }
    
    private func checkRecordedString(rule : GrammarRule, input: String, expectedToRecord: String) -> Bool {
        if rule.parse(input: input) != nil {
          return rule.stringValue! == expectedToRecord
        }
        if expectedToRecord == "" {
            return true
        }
        return false
    }
    
}
