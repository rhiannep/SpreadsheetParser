//
//  SpreadsheetGrammar.swift
//  COSC346 Assignment 1
//
//

import Foundation
/**
 * A GRNonTerminal is a GrammarRule thats string value is composed of the string values
 * of the rules that were applied in a successful parse. The calculated value of a rule is
 * not calculated here because the calculated value is specific to each rule.
 */
class GRNonTerminal : GrammarRule {
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if self.currentRuleSet != nil {
                var buildString = ""
                for rule in self.currentRuleSet! {
                    if !(rule is Epsilon) {
                        buildString += rule.stringValue!
                    }
                }
                self.stringValue = buildString
            }
            return rest
        }
        return nil
    }
}

class GRSpreadsheet : GRNonTerminal {
    let myGRExpression = GRExpression()
    init(){
        super.init(rhsRules: [[myGRExpression], [Epsilon.theEpsilon]])
    }
}

/// A GrammarRule for handling: Expression -> Integer ExpressionTail
class GRExpression : GRNonTerminal {
    let num = GRInteger()
    let exprTail = GRExpressionTail()

    init(){
        super.init(rhsRule: [num,exprTail])
    }
    override func parse(input: String) -> String? {
        let rest = super.parse(input:input)
        if rest != nil {
            self.calculatedValue = num.calculatedValue! + exprTail.calculatedValue!
        }
        return rest
    }
}

/// A GrammarRule for handling: ExpressionTail -> "+" Integer
class GRExpressionTail : GRNonTerminal {
    let plus = GRLiteral(literal: "+")
    let num = GRInteger()
    
    init(){
        super.init(rhsRule: [plus,num])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.calculatedValue =  Int(num.stringValue!)
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling ProductTerm -> Integer ProductTermTail
class GRProductTerm : GRNonTerminal {
    let num = GRInteger()
    let productTail = GRProductTermTail()
    
    init(){
        super.init(rhsRule: [num,productTail])
    }
    override func parse(input: String) -> String? {
        let rest = super.parse(input:input)
        if rest != nil {
            self.calculatedValue = num.calculatedValue! * productTail.calculatedValue!
        }
        return rest
    }
    
}

/// A Grammar Rule for handling ProductTermTail -> "*" Integer ProductTermTail | epsilon
class GRProductTermTail : GRNonTerminal {
    let times = GRLiteral(literal: "*")
    let num = GRInteger()
    var tail : GrammarRule = Epsilon.theEpsilon
    
    init() {
        super.init(rhsRules: [[times, num], [Epsilon.theEpsilon]])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.calculatedValue =  Int(num.stringValue!)
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
class GRAbsoluteCell : GRNonTerminal {
    let col = GRColumnLabel()
    let row = GRRowNumber()
    
    init() {
        super.init(rhsRule: [col, row])
    }

}

/// A Grammar Rule for handling RelativeCell -> r Integer c Integer
class GRRelativeCell : GRNonTerminal {
    let r = GRLiteral(literal: "r")
    let c = GRLiteral(literal: "c")
    let row = GRInteger()
    let col = GRInteger()
    
    init() {
        super.init(rhsRule: [r, row, c, col])
    }
}

/// A Grammar Rule for handling CellReference -> AbsoluteCell | RelativeCell
class GRCellReference : GRNonTerminal {
    let absolute = GRAbsoluteCell()
    let relative = GRRelativeCell()
    
    init() {
        super.init(rhsRules: [[absolute], [relative]])
    }
}

/// A Grammar Rule for handling Value -> CellReference | Integer
class GRValue : GRNonTerminal {
    let reference = GRCellReference()
    let number = GRInteger()
    
    init() {
        super.init(rhsRules: [[reference], [number]])
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


