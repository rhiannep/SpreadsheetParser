//
//  SpreadsheetModel.swift
//  SpreadsheetParser
//
//  Created by Rhianne Price on 12/08/17.
//  Copyright © 2017 Rhianne Price. All rights reserved.
//

import Foundation

/**
 * A struct for a dictionary of cell contents
 */
struct Cells {
    static var currentContext : CellReference? = nil
    static private var cells = [CellReference: CellContents]()
    static private var dependencies = [CellReference: [CellReference]]()
    
    static func add(_ ref : CellReference, _ contents: CellContents) {
        cells[ref] = contents
    }

    
    static func get(_ key : String) -> CellContents? {
        let reference = GRCellReference()
        
        if(reference.parse(input: key) == "") {
            return get(reference.cellReference!)
        }
        return nil
    }
    
    static func get(_ key: CellReference) -> CellContents {
        if cells[key] == nil {
            return CellContents()
        }
        return cells[key]!
    }
    
    static func refresh(_ cell: CellReference) {
        let newExpression = GRExpression()
        currentContext = cell
        if newExpression.parse(input: (cells[cell]?.expression)!) != nil {
            cells[cell] = CellContents(expression: newExpression.stringValue!, value: newExpression.calculatedValue)
            currentContext = nil
        }
    }
    
    static func getRefreshed(_ key : String) -> CellContents? {
        let reference = GRCellReference()
        if(reference.parse(input: key) == "") {
            return getRefreshed(reference.cellReference!)
        }
        return nil
    }
    
    static func getRefreshed(_ ref : CellReference) -> CellContents {
        let newExpression = GRExpression()
        newExpression.set(context: ref)
        if let cell = cells[ref] {
            if newExpression.parse(input: cell.expression) != nil {
                cells[ref] = CellContents(expression: newExpression.stringValue!, value: newExpression.calculatedValue)
                return cells[ref]!
            }
        }
        return CellContents()
    }
    
    static func clear() {
        cells.removeAll()
    }
}

/**
 * A cell reference class to be used as keys in a set of Cells
 * Provides functionality for converting between absolute and relative
 * references in the two initialisers. I have indexed absolute cells from
 * A1 and relative references from r0c0. 
 *
 * The tricky bit here is mapping the column label eg C or ZAB on to a column number
 * or vice versa. My implementation treats the column labelling as a base 26 number system
 * with digits from A-Z
 */
class CellReference : Hashable {
    let absolute : String
    
    let row : Int
    let column : Int
    
    var hashValue: Int {
        return absolute.hashValue
    }
    
    // Constructor takes arguments that directly translate to an absolute cell reference
    // and compute the row and column indexes
    //
    init(colLabel : String, rowLabel : Int) {
        absolute = colLabel + String(rowLabel)
        
        let unicodeUpperA = Int(UnicodeScalar("A").value)
        let alphabetCount = 26
        var places = colLabel.characters.count - 1
        var columnNumber = 0
        
        // For each letter in the column string add it's contribution to 
        // the final column number.
        for letter in colLabel.unicodeScalars {
            columnNumber += (Int(letter.value) - unicodeUpperA + 1) * Int(pow(Double(alphabetCount), Double(places)))
            places -= 1
        }
        
        row = rowLabel - 1
        column = columnNumber - 1
    }
    
    // Constructor takes an existing cell reference and computes
    init?(context: CellReference, rowOffset: Int, colOffset: Int) {
        if context.row + rowOffset < 0 || context.column + colOffset < 0 {
            return nil
        }
        
        row = context.row + rowOffset
        column = context.column + colOffset
        var columnNumber = column
        let unicodeUpperA = Int(UnicodeScalar("A").value)
        let alphabetCount = 26
        var columnLabel = ""
        var digit : Int
        var count = 1
        while columnNumber >= 0 {
            digit = columnNumber % Int(pow(Double(alphabetCount), Double(count))) + 1
            columnNumber -= digit
            digit /= Int(pow(Double(alphabetCount), Double(count - 1)))
            columnLabel += String(UnicodeScalar(digit + unicodeUpperA - 1)!)
            count += 1
        }
        absolute = String(columnLabel.characters.reversed()) + String(row + 1)
    }
    
    static func == (lhs: CellReference, rhs: CellReference) -> Bool {
        return lhs.absolute == rhs.absolute
    }
}

class CellValue {
    private var string : String?
    private var calculatedValue : Int?
    
    init() {
        string = nil
        calculatedValue = nil
    }
    
    convenience init(_ number: Int) {
        self.init()
        calculatedValue = number
    }
    
    func set(number: Int){
        self.calculatedValue = number
    }
    
    func set(string: String) {
        self.string = string;
    }
    
    func get() -> Int? {
        return self.calculatedValue
    }
    
    func describing() -> String {
        if self.string != nil {
            return string!
        }
        if self.calculatedValue != nil {
            return String(describing: self.calculatedValue!)
        }
        return ""
    }
    
    func copy() -> CellValue {
        let copy = CellValue()
        if self.string != nil {
            copy.set(string: self.string!)
        }
        
        if self.calculatedValue != nil {
            copy.set(number: self.calculatedValue!)
        }
        return copy
    }
    
    static func +=(cellValue1: CellValue, cellValue2: CellValue) {
        if cellValue1.get() != nil && cellValue2.get() != nil {
            cellValue1.set(number: cellValue1.get()! + cellValue2.get()!)
        }
    }
    
    static func *=(cellValue1: CellValue, cellValue2: CellValue) {
        if cellValue1.get() != nil && cellValue2.get() != nil {
            cellValue1.set(number: cellValue1.get()! * cellValue2.get()!)
        }
    }
    
    static func +(cellValue1: CellValue, cellValue2: CellValue) -> CellValue {
        let newCellValue = CellValue()
        if cellValue1.get() != nil && cellValue2.get() != nil {
            newCellValue.set(number: cellValue1.get()! + cellValue2.get()!)
        }
        return newCellValue
    }
    
    static func *(cellValue1: CellValue, cellValue2: CellValue) -> CellValue {
        let newCellValue = CellValue()
        if cellValue1.get() != nil && cellValue2.get() != nil {
            newCellValue.set(number: cellValue1.get()! * cellValue2.get()!)
        }
        return newCellValue
    }
}

/**
 * A struct to store the expression and value found in a cell of a Spreadsheet.
 */
struct CellContents {
    var expression : String = ""
    var value = CellValue(0)
}
