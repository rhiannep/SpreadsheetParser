//
//  GrammarRules.swift
//  COSC346 Assignment 1
//
//

import Foundation

class GRSpreadsheet : GrammarRule {
    let print = GRPrint()
    let assignment = GRAssignment()
    init(){
        super.init(rhsRules: [[assignment], [print], [Epsilon.theEpsilon]])
    }
}

// GrammarRule Parsing for print statements
// Print -> print_expr Expression Spreadsheet | print_value Expression Spreadsheet
class GRPrint : GrammarRule {
    let printValue = GRLiteral(literal: "print_value")
    let printExpression = GRLiteral(literal: "print_expr")
    let expression = GRExpression()
    
    init() {
        super.init(rhsRules: [[printValue, expression], [printExpression, expression]])
    }
    
    // If the input is parsed successfully as a print statement, the appropriate output
    // is printed to stdout depending on the print statement
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if let cell = Spreadsheet.theSpreadsheet.get(expression.stringValue!) {
                // If the expression was a reference to a cell, print the value or expression in the cell
                if(currentRuleSet?[0] === printExpression) {
                    print("Expression in cell \(expression.stringValue!) is \(cell.expression)")
                } else {
                    print("Value of cell \(expression.stringValue!) is \(cell.value.describing())")
                }
            } else {
                // If the expression was not a reference to a cell, print the value or expression
                // A less typical use case
                if(currentRuleSet?[0] === printExpression) {
                    print("Expression is \(expression.stringValue!)")
                } else {
                    print("Value is \(expression.calculatedValue.describing())")
                }
            }
            
            // Recursive part of the grammar. Parse the rest as a spreadsheet (which could be epsilon)
            let spreadsheet = GRSpreadsheet()
            let restOfRest = spreadsheet.parse(input: rest)
            currentRuleSet?.append(spreadsheet)
            return restOfRest
        }
        return nil
    }
}

/// A GrammarRule for handling: Assignment -> AbsoluteCell := Expression Spreadsheet
/// The parse method here saves the string value and calculated value of the expression on the model
/// for later access. If the parse is successful, the current context cell is se to the cell on 
/// the lhs of the assignment.
class GRAssignment : GrammarRule {
    let cellRef = GRAbsoluteCell()
    let equals = GRLiteral(literal: ":=")
    let expression = GRExpression()
    
    init() {
        super.init(rhsRule: [cellRef, equals, expression])
    }
    
    override func parse(input: String) -> String? {
        // Try just parse as a cell reference first to get the context for the expression
        if cellRef.parse(input: input) != nil {
            expression.set(context: cellRef.cellReference)
        } else {
            // Can return early if this preliminary parse fails
            return nil
        }
        if let rest = super.parse(input: input) {
            // Store this expression and value in the model on a succeful parse
            let contents = CellContents(expression: expression.stringValue!, value: expression.calculatedValue)
            Spreadsheet.theSpreadsheet.add(cellRef.cellReference!, contents)
            
            // Recursive part of the grammar. Parse the rest as a spreadsheet (which could be epsilon)
            let spreadsheet = GRSpreadsheet()
            let restOfRest = spreadsheet.parse(input: rest)
            currentRuleSet?.append(spreadsheet)
            return restOfRest
        }
        return nil
    }
}


/// A GrammarRule for handling: Expression -> ProductTerm ExpressionTail | QuotedString
class GRExpression : GRContextual {
    let num = GRProductTerm()
    let exprTail = GRExpressionTail()
    let quotedString = GRQuotedString()

    init(){
        super.init(rhsRules: [[num, exprTail], [quotedString]])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input:input) {
            if(self.currentRuleSet!.contains(where: { $0 === quotedString })) {
                self.calculatedValue.set(string: quotedString.stringValue!)
                return rest
            }
            if exprTail.rhsIsEpsilon() {
                self.calculatedValue = num.calculatedValue.copy()
            } else {
                self.calculatedValue = num.calculatedValue + exprTail.calculatedValue
            }
            return rest
        }
        self.nilify()
        return nil
    }
}

/// A GrammarRule for handling: ExpressionTail -> "+" ProductTerm ExpressionTail | Epsilon
class GRExpressionTail : GRContextual {
    let plus = GRLiteral(literal: "+")
    let num = GRProductTerm()
    
    init(){
        super.init(rhsRules: [[plus, num], [Epsilon.theEpsilon]])
    }
    
    // An implementation of the recursive tail part. If the input was successfully parsed as "*" Integer
    // A second GRProductTailTerm is instantiated, and then given the remaining input to try and parse itself.
    // If successful, the tails state are passed up to this instance and this instances state is adjusted accordingly.
    // I would have like to make this more object oriented by using the Epsilon parse differently but can't work it out.
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if self.rhsIsEpsilon() {
                // This must be an Epsilon parse so no need to record state or do a second parse.
                return input
            }
            self.calculatedValue = num.calculatedValue.copy()
            let tail = GRExpressionTail()
            if let restOfRest = tail.parse(input: rest) {
                self.currentRuleSet?.append(tail)
                if tail.rhsIsEpsilon() {
                    // Tail must be Epsilon, so return without updating state
                    return rest
                }
                self.calculatedValue += tail.calculatedValue
                self.stringValue! += tail.stringValue!
                return restOfRest
            }
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling ProductTerm -> Integer ProductTermTail
class GRProductTerm : GRContextual {
    let number = GRValue()
    let tail = GRProductTermTail()
    
    init(){
        super.init(rhsRule: [number, tail])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input:input) {
            if tail.rhsIsEpsilon(){
              self.calculatedValue = number.calculatedValue.copy()
            } else {
              self.calculatedValue = number.calculatedValue * tail.calculatedValue
            }
            return rest
        }
        return nil
    }
    
}

/// A Grammar Rule for handling ProductTermTail -> "*" Value ProductTermTail | epsilon
class GRProductTermTail : GRContextual {
    let times = GRLiteral(literal: "*")
    let num = GRValue()
    
    init() {
        super.init(rhsRules: [[times, num], [Epsilon.theEpsilon]])
    }
    
    // An implementation of the recursive tail part. If the input was successfully parsed as -> "*" Integer
    // A second GRProductTailTerm is instantiated, and then given the remaining input to try and parse itself.
    // If successful, the tails values are passed up to this instance and this instances state is adjusted accordingly.
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if self.rhsIsEpsilon() {
                // The RHS rule is epsilon, return without updating state
                return input
            }
            self.calculatedValue = num.calculatedValue.copy()
            let tail = GRProductTermTail()
            if let restOfRest = tail.parse(input: rest) {
                self.currentRuleSet?.append(tail)
                if tail.rhsIsEpsilon() {
                    // Tail is really just epsilon, return without updating state
                    return rest
                }
                self.calculatedValue *= tail.calculatedValue
                self.stringValue! += tail.stringValue!
                self.currentRuleSet?.append(tail)
                return restOfRest
            }
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling ColumnLabel -> UpperAlphaString
class GRColumnLabel : GRNonTerminal {
    let label = GRUpperAlphaString()
    init() {
        super.init(rhsRule: [label])
    }
}

/// A Grammar Rule for handling RowNumber -> PositiveInteger
class GRRowNumber : GRNonTerminal {
    let label = GRPositiveInteger()
    init() {
        super.init(rhsRule: [label])
    }
}

/// A Grammar Rule for handling AbsoluteCell -> ColumnLabel RowNumber
class GRAbsoluteCell : GRCell {
    let col = GRColumnLabel()
    let row = GRRowNumber()

    init() {
        super.init(rhsRule: [col, row])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            cellReference = CellReference(colLabel: col.stringValue!, rowLabel: Int(row.stringValue!)!)
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling RelativeCell -> r Integer c Integer
class GRRelativeCell : GRCell {
    let r = GRLiteral(literal: "r")
    let c = GRLiteral(literal: "c")
    let row = GRInteger()
    let col = GRInteger()
    
    init() {
        super.init(rhsRule: [r, row, c, col])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if let context = self.context {
                if let ref = CellReference(context: context, rowOffset: row.calculatedValue.get()!, colOffset: col.calculatedValue.get()!) {
                    cellReference = ref
                    return rest
                }
            }
        }
        self.nilify()
        return nil
    }
}

/// A Grammar Rule for handling CellReference -> AbsoluteCell | RelativeCell
class GRCellReference : GRCell {
    let absolute = GRAbsoluteCell()
    let relative = GRRelativeCell()
    
    init() {
        super.init(rhsRules: [[absolute], [relative]])
    }

    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if let cell = currentRuleSet?[0] as? GRCell {
                cellReference = cell.cellReference
            }
            return rest
        }
        return nil
    }
}


/// A Grammar Rule for handling Value -> CellReference | Integer
class GRValue : GRContextual {
    let reference = GRCellReference()
    let number = GRInteger()
    
    init() {
        super.init(rhsRules: [[reference], [number]])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if let cell = currentRuleSet?[0] as? GRCell {
                self.calculatedValue = Spreadsheet.theSpreadsheet.get(cell.cellReference!).value.copy()
            } else {
                self.calculatedValue = number.calculatedValue.copy()
            }
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling QuotedString -> " StringNoQuote "
class GRQuotedString : GRNonTerminal {
    let quoteMark = GRLiteral(literal: "\"")
    let string = GRStringNoQuote()
    
    init() {
        super.init(rhsRule: [quoteMark, string, quoteMark])
    }
}


