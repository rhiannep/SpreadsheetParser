//
//  SpreadsheetGrammar.swift
//  COSC346 Assignment 1
//
//

import Foundation

class GRPrint : GrammarRule {
    let printValue = GRLiteral(literal: "print_value")
    let printExpression = GRLiteral(literal: "print_expr")
    let expression = GRExpression()
    
    init() {
        super.init(rhsRules: [[printValue, expression], [printExpression, expression]])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if let cell = GrammarRule.cells.get(expression.stringValue!) {
                if(currentRuleSet?[0] === printExpression) {
                    print("Expression in cell \(expression.stringValue!) is \(cell.expression)")
                } else {
                    print("Value in cell \(expression.stringValue!) is \(cell.value)")
                }
            } else {
                if(currentRuleSet?[0] === printExpression) {
                    print("Expression is \(expression.stringValue!)")
                } else {
                    print("Value is \(expression.calculatedValue!)")
                }
            }
            return rest
        }
        return nil
    }
}
class GRAssignment : GrammarRule {
    let cellRef = GRAbsoluteCell()
    let equals = GRLiteral(literal: ":=")
    let expression = GRExpression()
    
    init() {
        super.init(rhsRule: [cellRef, equals, expression])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            let contents = CellContents(expression: expression.stringValue!, value: expression.calculatedValue!)
            GrammarRule.cells.add(cellRef.cellReference!, contents)
            return rest
        }
        return nil
    }
}
/**
 * A GRNonTerminal is a GrammarRule thats right hand side rues contain more grammar rules.
 * The string value of a non-terminal rule is composed of the string values
 * of the right hand side rules that were applied in a successful parse. The calculated value of a rule is
 * not calculated here because the calculated value is specific to each rule.
 */
class GRNonTerminal : GrammarRule {
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if self.currentRuleSet != nil {
                var buildString = ""
                for rule in self.currentRuleSet! {
                    if !(rule.rhsIsEpsilon() || rule is Epsilon) {
                        buildString += rule.stringValue!
                    }
                }
                if !self.rhsIsEpsilon() { self.stringValue = buildString }
            }
            return rest
        }
        return nil
    }
}

class GRSpreadsheet : GRNonTerminal {
    let aGRPrint = GRPrint()
    let aGRAssignment = GRAssignment()
    init(){
        super.init(rhsRules: [[aGRAssignment], [aGRPrint], [Epsilon.theEpsilon]])
    }
}

/// A GrammarRule for handling: Expression -> ProductTerm ExpressionTail | QuotedString
class GRExpression : GRNonTerminal {
    let num = GRProductTerm()
    let exprTail = GRExpressionTail()
    let quotedString = GRQuotedString()

    init(){
        super.init(rhsRules: [[num, exprTail], [quotedString]])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input:input) {
            if(self.currentRuleSet!.contains(where: { $0 === quotedString })) {
                 self.calculatedValue = 0
                 return rest
            }
            if exprTail.rhsIsEpsilon() {
                self.calculatedValue = num.calculatedValue!
            } else {
                self.calculatedValue = num.calculatedValue! + exprTail.calculatedValue!
            }
            return rest
        }
        self.nilify()
        return nil
    }
}

/// A GrammarRule for handling: ExpressionTail -> "+" ProductTerm ExpressionTail | Epsilon
class GRExpressionTail : GRNonTerminal {
    let plus = GRLiteral(literal: "+")
    let num = GRProductTerm()
    
    init(){
        super.init(rhsRules: [[plus, num], [Epsilon.theEpsilon]])
    }
    
    // A hacky implementation of the recursive tail part. If the input was successfully parsed as -> "*" Integer
    // A second GRProductTailTerm is instantiated, and then given the remaining input to try and parse itself.
    // If successful, the tails state are passed up to this instance and this instances state is adjusted accordingly.
    // I would have like to make this more object oriented by using the Epsilon parse differently but can't work it out.
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if self.rhsIsEpsilon() { return input } // This must be an Epsilon parse so no need to record state or do a second parse.
            self.calculatedValue = num.calculatedValue!
            let tail = GRExpressionTail()
            if let restOfRest = tail.parse(input: rest) {
                self.currentRuleSet?.append(tail)
                if tail.rhsIsEpsilon() { return rest } // Tail must be Epsilon, so return without updating state
                self.calculatedValue! += tail.calculatedValue!
                self.stringValue! += tail.stringValue!
                return restOfRest
            }
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling ProductTerm -> Integer ProductTermTail
class GRProductTerm : GRNonTerminal {
    let num = GRValue()
    let productTail = GRProductTermTail()
    
    init(){
        super.init(rhsRule: [num, productTail])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input:input) {
            if productTail.rhsIsEpsilon(){
              self.calculatedValue = num.calculatedValue!
            } else {
              self.calculatedValue = num.calculatedValue! * productTail.calculatedValue!
            }
            return rest
        }
        return nil
    }
    
}

/// A Grammar Rule for handling ProductTermTail -> "*" Value ProductTermTail | epsilon
class GRProductTermTail : GRNonTerminal {
    let times = GRLiteral(literal: "*")
    let num = GRValue()
    
    init() {
        super.init(rhsRules: [[times, num], [Epsilon.theEpsilon]])
    }
    
    // A hacky implementation of the recursive tail part. If the input was successfully parsed as -> "*" Integer
    // A second GRProductTailTerm is instantiated, and then given the remaining input to try and parse itself.
    // If successful, the tails values are passed up to this instance and this instances state is adjusted accordingly.
    // I would have like to make this more object oriented by using the Epsilon parse but can't work it out.
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if self.rhsIsEpsilon() {
                // The RHS rule is epsilon, return without updating state
                return input
            }
            self.calculatedValue = num.calculatedValue!
            let tail = GRProductTermTail()
            if let restOfRest = tail.parse(input: rest) {
                self.currentRuleSet?.append(tail)
                if tail.rhsIsEpsilon() {
                    // Tail is really just epsilon, return without updating state
                    return rest
                }
                self.calculatedValue! *= tail.calculatedValue!
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
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.calculatedValue = label.calculatedValue!
            return rest
        }
        return nil
    }
    
}

protocol HasACellReference {
    var cellReference : CellReference? { get }
}

/// A Grammar Rule for handling AbsoluteCell -> ColumnLabel RowNumber
class GRAbsoluteCell : GRNonTerminal, HasACellReference {
    let col = GRColumnLabel()
    let row = GRRowNumber()
    
    var cellReference: CellReference?
    
    init() {
        super.init(rhsRule: [col, row])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            cellReference = CellReference(columnRef: col.stringValue!, rowNumber: row.calculatedValue!)
            return rest
        }
        cellReference = nil // Make grammar rule reusable
        return nil
    }

}

/// A Grammar Rule for handling RelativeCell -> r Integer c Integer
class GRRelativeCell : GRNonTerminal, HasACellReference {
    let r = GRLiteral(literal: "r")
    let c = GRLiteral(literal: "c")
    let row = GRInteger()
    let col = GRInteger()
    
    var cellReference: CellReference?
    
    init() {
        super.init(rhsRule: [r, row, c, col])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            cellReference = CellReference(row: row.calculatedValue!, column: col.calculatedValue!)
            return rest
        }
        cellReference = nil // Make grammar rule reusable
        return nil
    }
}

/// A Grammar Rule for handling CellReference -> AbsoluteCell | RelativeCell
class GRCellReference : GRNonTerminal, HasACellReference {
    var cellReference: CellReference?
    let absolute = GRAbsoluteCell()
    let relative = GRRelativeCell()
    
    init() {
        super.init(rhsRules: [[absolute], [relative]])
    }

    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if(currentRuleSet?[0] === absolute) {
                cellReference = absolute.cellReference
            } else if(currentRuleSet?[0] === relative) {
               cellReference = relative.cellReference
            }
            return rest
        }
        cellReference = nil // Make grammar rule reusable
        return nil
    }
}


/// A Grammar Rule for handling Value -> CellReference | Integer
class GRValue : GRNonTerminal {
    let reference = GRCellReference()
    let number = GRInteger()
    
    init() {
        super.init(rhsRules: [[reference], [number]])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if(currentRuleSet?[0] === reference) {
                self.calculatedValue = GrammarRule.cells.get(reference.cellReference!).value
            } else if currentRuleSet?[0] === number {
                self.calculatedValue = number.calculatedValue!
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


