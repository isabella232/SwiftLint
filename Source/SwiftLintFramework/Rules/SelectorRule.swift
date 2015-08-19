//
//  SelectorRule.swift
//  SwiftLint
//
//  Created by Keith Smiley on 8/18/15.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SourceKittenFramework

public struct SelectorRule: Rule {
    public init() {}

    public let identifier = "selector"

    private static let regex = NSRegularExpression(pattern: "[\\W\\s]+Selector\\(",
        options: nil, error: nil)!

    public func validateFile(var file: File) -> [StyleViolation] {
        let range = NSRange(location: 0, length: count(file.contents))
        let matches = SelectorRule.regex.matchesInString(file.contents,
            options: nil, range: range) as? [NSTextCheckingResult] ?? []

        return matches.map { match in
            return StyleViolation(type: .Selector,
                location: Location(file: file, offset: match.range.location),
                severity: .Medium,
                reason: "Don't use Selector")
        }
    }

    public let example = RuleExample(ruleName: "Selector",
        ruleDescription: "Don't use Selector()",
        nonTriggeringExamples: [
            "addTarget(self, \"foo\")",
            "somethingSelector(self)",
        ],
        triggeringExamples: [
            "addTarget(self, Selector(\"foo\"))",
            "let foo = Selector(\"foo\")",
            "foo(Selector(\"bar\")",
        ]
    )
}
