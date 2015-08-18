//
//  Linter.swift
//  SwiftLint
//
//  Created by JP Simard on 2015-05-16.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation
import SwiftXPC
import SourceKittenFramework

private let kPragma = "// PRAGMA LINT: "

public struct Linter {
    private let file: File

    private let rules: [Rule] = [
        LineLengthRule(),
        LeadingWhitespaceRule(),
        TrailingWhitespaceRule(),
        ReturnArrowWhitespaceRule(),
        TrailingNewlineRule(),
        OperatorFunctionWhitespaceRule(),
        FileLengthRule(),
        TodoRule(),
        ColonRule(),
        TypeNameRule(),
        VariableNameRule(),
        TypeBodyLengthRule(),
        NestingRule(),
        ControlStatementRule(),
        DocumentationCommentRule(),
    ]

    public var styleViolations: [StyleViolation] {
        var activeRules = rules
        if file.contents.hasPrefix(kPragma),
            let range = file.contents.rangeOfString("\n")
        {
            let firstLine = file.contents.substringToIndex(range.endIndex)
            let excludedIdentifiers = split(firstLine) { $0 == " " }.map { $0.stripped }

            activeRules = rules.filter { rule in
                for excludedIdentifier in excludedIdentifiers {
                    if "-\(rule.identifier)" == excludedIdentifier {
                        return false
                    }
                }

                return true
            }
        }

        return activeRules.flatMap { $0.validateFile(file) }
    }

    public var ruleExamples: [RuleExample] {
        return compact(rules.map { $0.example })
    }

    /**
    Initialize a Linter by passing in a File.

    :param: file File to lint.
    */
    public init(file: File) {
        self.file = file
    }
}
