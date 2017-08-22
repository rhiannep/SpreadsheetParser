//
//  main.swift
//  SpreadsheetParser
//
//  Created by Rhianne Price on 11/08/17.
//  Copyright © 2017 Rhianne Price. All rights reserved.
//

import Foundation

if CommandLine.arguments.count>1 {
    var filenames = CommandLine.arguments
    filenames.removeFirst() // first argument is the name of the executable
    
    func stderrPrint(_ message:String) {
        let stderr = FileHandle.standardError
        stderr.write(message.data(using: String.Encoding.utf8)!)
    }
    
    for filename in filenames {
        do {
            let filecontents : String = try String.init(contentsOfFile: filename)
            let aGRSpreadsheet = GRSpreadsheet()
            if let remainder = aGRSpreadsheet.parse(input: filecontents) {
                if remainder != "" {
                    stderrPrint("Parsing left remainder [\(remainder)].\n")
                }
            }
        } catch {
            stderrPrint("Error opening and reading file with filename [\(filename)].\n")
        }
    }
}








