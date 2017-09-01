//
//  BaseGrammar.swift
//  COSC346 Assignment 1
//
//  Provides the top-level classes for recursive descent parsing

import Foundation

/**
 Each GrammarRule class is intended to parse a single rule from a grammar specification.
 
 Remember that the right-hand-side of a grammar rule is a list of alternative expansions, and each option is a list of grammar rules.
 
 The base GrammarRule class has a parse method that attempts in turn to parse each alternative GrammarRule list.
 */
class GrammarRule {
    
    /// A GrammarRule instance will have a stringValue when it parses something successfully
    var stringValue : String? = nil
    /// A GrammarRule instance may have a calculatedValue, although really this should be in a subclass and is a hack to facilitate a simple example.
    var calculatedValue = CellValue()
    
    /// Keep track of the rule set that has been successfully used in a parse
    var currentRuleSet : [GrammarRule]? = nil
    
    /// The list of possible right-hand-side options, each of which is a GrammarRule list.
    let rhs : [[GrammarRule]]
    
    /**
     This initaliser takes in a list of the possible right-hand-side options.
     Each option is itself a GrammarRule list.
     */
    init(rhsRules : [[GrammarRule]]){
        rhs = rhsRules
    }
    /// Accept a single right-hand option also.
    init(rhsRule : [GrammarRule]) {
        rhs = [rhsRule]
    }

    /**
     The GrammarRule parse method will try each right-hand-side GrammarRule in turn until one succeeds, or returns nil otherwise.
     */
    func parse(input : String) -> String? {
        var remainingInput = input
        
        ruleLoop: for ruleChoice in rhs {
            // Each of the RHS options should be given the whole input to try to parse.
            remainingInput = input
            for rule in ruleChoice {
                if let rest = rule.parse(input: remainingInput) {
                    remainingInput = rest
                } else {
                    // Failing to parse any GrammarRule within a RHS choice means we failed to parse that RHS choice and should try the next choice (if there is one).
                    continue ruleLoop
                }
            }
            currentRuleSet = ruleChoice // record which rules were used when something is parsed successfully
            if rhsIsEpsilon() { nilify() }
            return remainingInput
        }
        // Make each grammar rule instance reuseable, no old state is stored after an unsuccessful parse
        nilify()
        return nil
    }
    
    /**
     Function to wipe the state of this grammar rule
     */
    func nilify() {
        self.stringValue = nil
        self.calculatedValue = CellValue()
    }
    
    /**
     Checks if the most recent parse was an epsilon parse
     */
    func rhsIsEpsilon() -> Bool {
        if currentRuleSet == nil {
            return false
        }
        return currentRuleSet![0] is Epsilon && currentRuleSet!.count == 1
    }
    
}

/**
 There should only be a single Epsilon GrammarRule.
 Here we develop a means to instantiate it.
 This effects a form of the singleton pattern.
 */
class Epsilon : GrammarRule {
    /// An Epsilon parse consumes nothing from the input string, so returns all of the input as the remaining string to be parsed.
    override func parse(input : String) -> String? {
        return input
    }

    /// The idea is for constructors to be private, although the access control in this particular implementation was not tested.
    private init(){
        super.init(rhsRules: [])
    }
    override private init(rhsRules: [[GrammarRule]]) {
        super.init(rhsRules: [])
    }
    
    /// theEpsilon is the instantiated singleton; thus is a class property.
    static let theEpsilon = Epsilon()
}
/**
 A GRNonTerminal is a grammar rule that has rhs rules that aren't tokens.
 After a successful parse, this grammar rules string value should be set to the concatenation of the string values of the rhs rules that were used in the parse.
 This allows for some generalisation of some of the parse functionality, but calulating the value for the grammar rule is more specific to each grammar rule.
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
                if !self.rhsIsEpsilon() {
                    self.stringValue = buildString
                }
            }
            return rest
        }
        return nil
    }
}


/**
 A class that adds more specificty to GrammarRule
 A GRContextual is a grammar rule that may need a context to be evaluated. A relative cell reference needs a cell to be relative to. Any grammar rule that could contain a relative cell needs to keep a reference to the context cell incase a relative cell comes up in a parse.
 */
class GRContextual : GRNonTerminal {
    var context : CellReference?
    
    // Setting a grammar rule's context will recursively set all its context dependent rhs rules
    func set(context: CellReference?) {
        self.context = context
        for ruleChoice in self.rhs {
            for rule in ruleChoice {
                if let contextRule = rule as? GRContextual {
                    contextRule.set(context: context)
                }
            }
        }
    }
    
    // An extra field to nilify
    override func nilify() {
        super.nilify()
        self.context = nil
    }
}

/// A subclass of GRNonTerminal to make sure all state gets wiped for Grammar rules that have a cell reference.
class GRCell : GRContextual {
    var cellReference: CellReference?
    
    override func nilify() {
        super.nilify()
        cellReference = nil
    }
}

/**
  A data structure for representing the value in a cell.
  The value in a cell can have an integer or a string. A cell value's integer value is the calculated value in that cell, or nil if the cell contains a quoted string. A cell value's string is the quoted string in that cell.
 */
class CellValue {
    private var string : String?
    private var calculatedValue : Int?
    
    static let theEmptyCell = CellValue()
    
    // Cell value has no state by default
    init() {
        string = nil
        calculatedValue = nil
    }
    
    // An initialiser for a cell value with an integer
    convenience init(_ number: Int) {
        self.init()
        calculatedValue = number
    }
    
    // Setter for the integer value
    func set(number: Int){
        self.calculatedValue = number
    }
    
    // Setter for the string value
    func set(string: String) {
        self.string = string;
    }
    
    // Getter for the integer
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
    
    // Returns a copy of this CellValue
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
    
    // Operator overloading for +=
    // Only changesthe integer value part of this cell value, if it has one
    static func +=(cellValue1: CellValue, cellValue2: CellValue) {
        if cellValue1.get() != nil && cellValue2.get() != nil {
            cellValue1.set(number: cellValue1.get()! + cellValue2.get()!)
        }
    }
    
    // Operator overloading for *=
    // Only changesthe integer value part of this cell value, if it has one
    static func *=(cellValue1: CellValue, cellValue2: CellValue) {
        if cellValue1.get() != nil && cellValue2.get() != nil {
            cellValue1.set(number: cellValue1.get()! * cellValue2.get()!)
        }
    }
    
    // Operator overloading for +
    // Only changesthe integer value part of this cell value, if it has one
    static func +(cellValue1: CellValue, cellValue2: CellValue) -> CellValue {
        let newCellValue = CellValue()
        if cellValue1.get() != nil && cellValue2.get() != nil {
            newCellValue.set(number: cellValue1.get()! + cellValue2.get()!)
        }
        return newCellValue
    }
    
    // Operator overloading for *
    // Only changesthe integer value part of this cell value, if it has one
    static func *(cellValue1: CellValue, cellValue2: CellValue) -> CellValue {
        let newCellValue = CellValue()
        if cellValue1.get() != nil && cellValue2.get() != nil {
            newCellValue.set(number: cellValue1.get()! * cellValue2.get()!)
        }
        return newCellValue
    }
}




