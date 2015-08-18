//
//  HeaderCommentRule.swift
//  SwiftLint
//
//  Created by Keith Smiley on 8/18/15.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SourceKittenFramework

public struct HeaderCommentRule: Rule {
    public init() {}

    public let identifier = "header_comment"

    private let regex = NSRegularExpression(pattern: "//\\s+Copyright",
        options: nil, error: nil)!

    public func validateFile(var file: File) -> [StyleViolation] {
        let lines = file.lines
        for (i, line) in enumerate(file.lines) {
            let content = line.content
            if !content.hasPrefix("//") {
                break
            }

            let range = NSRange(location: 0, length: count(content))
            let matches = regex.matchesInString(content, options: nil, range: range)
            if matches.count > 0 {
                return [StyleViolation(type: .HeaderComment,
                    location: Location(file: file, offset: line.index),
                    reason: "Files should not have header comments")]
            }
        }

        return []
    }


    public let example = RuleExample(ruleName: "Header Comment",
        ruleDescription: "Files should not have header comments",
        nonTriggeringExamples: [],
        triggeringExamples: [ "// Copyright" ]
    )
}
