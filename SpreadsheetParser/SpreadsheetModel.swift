//
//  SpreadsheetModel.swift
//  SpreadsheetParser
//
//  Created by Rhianne Price on 12/08/17.
//  Copyright © 2017 Rhianne Price. All rights reserved.
//

import Foundation

/**
 * A wrapper class for a dictionary of cell contents
 */
class Cells {
    private var cells = [CellReference: CellContents]()
    
    func add(_ ref : CellReference, _ contents: CellContents) {
        cells[ref] = contents
    }
    
    func get(_ key : String) -> CellContents? {
        let reference = GRCellReference()
        
        if(reference.parse(input: key) == "") {
            return get(reference.cellReference!)
        }
        return nil
    }
    
    func get(_ key: CellReference) -> CellContents {
        if cells[key] == nil {
            return CellContents()
        }
        return cells[key]!
    }
    
    func clear() {
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
    let relative : String
    var hashValue: Int {
        return relative.hashValue
    }
    
    // Constructor takes arguments that directly translate to an absolute cell reference
    // and compute the corresponding relative cell reference.
    //
    init(columnRef : String, rowNumber : Int) {
        absolute = columnRef + String(rowNumber)
        
        let unicodeUpperA = Int(UnicodeScalar("A").value)
        let alphabetCount = 26
        var places = columnRef.characters.count - 1
        var columnNumber = 0
        
        // For each letter in the column string add it's contribution to 
        // the final column number.
        for letter in columnRef.unicodeScalars {
            columnNumber += (Int(letter.value) - unicodeUpperA + 1) * Int(pow(Double(alphabetCount), Double(places)))
            places -= 1
        }
        
        relative = "r" + String(rowNumber - 1) + "c" + String(columnNumber - 1)
    }
    
    // Constructor takes arguments that directly translate to a relative cell reference
    // and compute the corresponding absolute cell reference.
    init(row: Int, column: Int) {
        relative = "r" + String(row) + "c" + String(column)
        
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
        return lhs.absolute == rhs.absolute || lhs.relative == rhs.relative
    }
}

/**
 * A struct to store the expression and value found in a cell of a Spreadsheet.
 */
struct CellContents {
    var expression : String = ""
    var value : Int = 0
}
