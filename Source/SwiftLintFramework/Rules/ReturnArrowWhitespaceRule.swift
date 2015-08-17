//
//  ReturningWhitespaceRule.swift
//  SwiftLint
//
//  Created by Akira Hirakawa on 2/6/15.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework

public struct ReturnArrowWhitespaceRule: Rule {
    public init() {}

    public let identifier = "return_arrow_whitespace"
    private static let MatchRegex = try! NSRegularExpression(pattern: "(\\)\\s*->[^\\n|\\s]|\\)->[\\n|\\s]|\\)\\s{2,}->\\s{2,})", options: [])

    public func validateFile(file: File) -> [StyleViolation] {
        let range = NSRange(location: 0, length: count(file.contents))
        let matches = ReturnArrowWhitespaceRule.MatchRegex.matchesInString(file.contents,
            options: nil, range: range) as? [NSTextCheckingResult] ?? []

        return matches.map { match in
            return StyleViolation(type: .ReturnArrowWhitespace,
                location: Location(file: file, offset: match.range.location),
                severity: .Warning,
                reason: "File should have 1 space before return arrow and return type")
        }
    }

    public let example = RuleExample(
        ruleName: "Returning Whitespace Rule",
        ruleDescription: "This rule checks whether you have 1 space before " +
        "return arrow and return type. Newlines are also acceptable.",
        nonTriggeringExamples: [
            "func abc() -> Int {}\n",
            "func abc() -> [Int] {}\n",
            "func abc() -> (Int, Int) {}\n",
            "var abc = {(param: Int) -> Void in }\n",
            "func abc() ->\n    Int {}\n",
            "func abc()\n    -> Int {}\n"
        ],
        triggeringExamples: [
            "func abc()->Int {}\n",
            "func abc()->[Int] {}\n",
            "func abc()->(Int, Int) {}\n",
            "func abc()-> Int {}\n",
            "func abc() ->Int {}\n",
            "func abc()  ->  Int {}\n",
            "var abc = {(param: Int) ->Bool in }\n",
            "var abc = {(param: Int)->Bool in }\n",
        ]
    )
}
