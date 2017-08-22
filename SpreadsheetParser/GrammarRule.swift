//
//  GrammarRule.swift
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
    
    func nilify() {
        self.stringValue = nil
        self.calculatedValue = CellValue()
    }
    
    func rhsIsEpsilon() -> Bool {
        if currentRuleSet == nil {
            return false
        }
        return currentRuleSet![0] is Epsilon && currentRuleSet!.count == 1
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




