//
//  TrailingWhitespaceRule.swift
//  SwiftLint
//
//  Created by JP Simard on 2015-05-16.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SourceKittenFramework

public struct TrailingWhitespaceRule: Rule {
    public init() {}

    public let identifier = "trailing_whitespace"

    public func validateFile(var file: File) -> [StyleViolation] {
        return file.lines.filter { line in
            return self.lastCharacterIsWhitespace(line)
        }.map {
            StyleViolation(type: .TrailingWhitespace,
                location: Location(file: file.path, line: $0.index),
                severity: .Medium,
                reason: "Line #\($0.index) should have no trailing whitespace")
        }
    }

    private func lastCharacterIsWhitespace(line: Line) -> Bool {
        if line.content.startIndex == line.content.endIndex {
            return false
        }

        let start = advance(line.content.endIndex, -1, line.content.startIndex)
        let range = Range(start: start, end: line.content.endIndex)
        let substring = line.content[range].utf16

        let char = substring[substring.startIndex]
        return NSCharacterSet.whitespaceCharacterSet().characterIsMember(char)
    }

    public let example = RuleExample(
        ruleName: "Trailing Whitespace Rule",
        ruleDescription: "This rule checks whether you don't have any trailing whitespace.",
        nonTriggeringExamples: [ "//\n", "\n", "", "\n\n" ],
        triggeringExamples: [ "// \n" ],
        showExamples: false
    )
}
