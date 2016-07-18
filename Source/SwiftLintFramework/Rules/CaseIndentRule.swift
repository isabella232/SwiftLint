//
//  CaseIndentRule.swift
//  SwiftLint
//
//  Created by Keith Smiley on 11/13/15.
//  Copyright © 2015 Realm. All rights reserved.
//

import SourceKittenFramework

private let switchRegex = try! NSRegularExpression(pattern: "^\\s*switch\\b",
    options: .AnchorsMatchLines)
private let caseRegex = try! NSRegularExpression(pattern: "^\\s*(case|default)\\b",
    options: .AnchorsMatchLines)
private let numberOfSpaces = 4

// swiftlint:disable function_body_length
public struct CaseIndentRule: Rule {
    public init() {}

    public static let description = RuleDescription(
        identifier: "case_indent",
        name: "Case statement indention",
        description: "Checks that case statements are one level deeper than switch",
        nonTriggeringExamples: [
            "switch foo {\n    case bar:\nbreak\n}",
        ],
        triggeringExamples: [
            "switch foo {\ncase bar:\nbreak\n}",
            "switch foo {\n    case bar:\nif foo {}\ncase baz:\n}",
            "switch foo {\n    case bar:\nbreak\ndefault: break\n}",
        ]
    )

    public func validateFile(file: File) -> [StyleViolation] {
        let lines = file.lines.map { $0.content }
        var inSwitchStatement = false
        var bracketDepth = 0
        var switchIndent: Int?
        var violations = [StyleViolation]()

        for (i, line) in lines.enumerate() {
            if !inSwitchStatement && switchRegex.hasMatch(line) {
                inSwitchStatement = true
                let trimmed = line.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceCharacterSet())
                switchIndent = line.characters.count - trimmed.characters.count

                if line.characters.contains("{") {
                    bracketDepth += 1
                }

                continue
            }

            guard inSwitchStatement, let switchIndent = switchIndent else {
                continue
            }

            if caseRegex.hasMatch(line) {
                let trimmed = line.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceCharacterSet())
                let indent = line.characters.count - trimmed.characters.count
                if indent - switchIndent != numberOfSpaces {
                    violations += [StyleViolation(ruleDescription: self.dynamicType.description,
                        location: Location(file: file.path, line: i),
                        reason: "'case' should be indented more than 'switch'")]
                }
            }

            if line.characters.contains("{") {
                bracketDepth += 1
            }

            if line.characters.contains("}") {
                bracketDepth -= 1
            }

            if bracketDepth == 0 {
                inSwitchStatement = false
            }
        }

        return violations
    }
}

private extension NSRegularExpression {
    func hasMatch(string: String) -> Bool {
        return self.firstMatchInString(string, options: [],
            range: NSRange(location: 0, length: string.characters.count)) != nil
    }
}
