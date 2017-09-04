//
//  SpreadsheetModel.swift
//  SpreadsheetParser
//
//  Created by Rhianne Price on 12/08/17.
//  Copyright © 2017 Rhianne Price. All rights reserved.
//
// A model to store the contents of a spreadsheet, including the appropriate data structures.
//

import Foundation

/**
  A singleton class for storing the values of spreadsheet expressions once the input has been successfully parsed
 */
class Spreadsheet {
    
    // the singleton instance of spreadsheet
    static let theSpreadsheet = Spreadsheet()
    
    //cells of the spreadsheet are cell contents indexed by cell references
    private var cells = [CellReference: CellContents]()
    
    // Add contents to the spreadsheet at the given cell
    func add(_ ref : CellReference, _ contents: CellContents) {
        cells[ref] = contents
    }
    
    // A convenience method for retrieving refreshed data from the model given a string representing an absolute cell reference
    // I have reused the parsing functionality from the grammar to convert from the string to a cell reference.
    func get(_ key : String) -> CellContents? {
        let reference = GRCellReference()
        if(reference.parse(input: key) == "") {
            return get(reference.cellReference!)
        }
        return nil
    }
    
    // Gets the refreshed data from the spreadsheet. To refresh the data the expression s reparsed and recalculated.
    // Infinite recursion happens here in the case of circular references.
    func get(_ ref : CellReference) -> CellContents {
        let newExpression = GRExpression()
        newExpression.set(context: ref)
        if let cell = cells[ref] {
            if newExpression.parse(input: cell.expression) != nil {
                cells[ref] = CellContents(expression: newExpression.stringValue!, value: newExpression.calculatedValue)
                return cells[ref]!
            }
        }
        return CellContents.theEmptyCell
    }
    
    func clear() {
        cells.removeAll()
    }
}

/**
 A cell reference class to be used as keys in a set of Cells. Provides functionality for converting from relative to absolute references.
 
 The tricky bit here is mapping the column label eg C or ZAB on to a column number or vice versa.
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
    
    /**
     Constructor takes an existing cell reference and computes the new row and column number, and the corresponding column label as a letter.
     This initialiser can return nil, as a relative cell reference could be invalid, ie a relative cell reference could go out of range of the spreadsheet.
    */
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

/**
 A struct to store the expression and value found in a cell of a Spreadsheet.
 */
struct CellContents {
    var expression : String
    var value : CellValue
    
    // A singleton for an empty cell
    static let theEmptyCell = CellContents(expression: "", value: CellValue(0))
}
