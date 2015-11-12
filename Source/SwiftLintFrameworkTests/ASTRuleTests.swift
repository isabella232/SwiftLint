//
//  ASTRuleTests.swift
//  SwiftLint
//
//  Created by JP Simard on 5/28/15.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SwiftLintFramework
import XCTest

class ASTRuleTests: XCTestCase {
    func testTypeNames() {
        for kind in ["class", "struct", "enum"] {
            XCTAssertFalse(violations("\(kind) Abc {}\n")
                .map { $0.ruleDescription.identifier }
                .contains(TypeNameRule.description.identifier))

            XCTAssertTrue(violations("\(kind) Ab_ {}\n").contains(StyleViolation(
                ruleDescription: TypeNameRule.description,
                severity: .Error,
                location: Location(file: nil, line: 1, character: 1),
                reason: "Type name should only contain alphanumeric characters: 'Ab_'")))

            XCTAssertTrue(violations("\(kind) abc {}\n").contains(StyleViolation(
                ruleDescription: TypeNameRule.description,
                severity: .Error,
                location: Location(file: nil, line: 1, character: 1),
                reason: "Type name should start with an uppercase character: 'abc'")))

            XCTAssertTrue(violations("\(kind) A {}\n").contains(StyleViolation(
                ruleDescription: TypeNameRule.description,
                location: Location(file: nil, line: 1, character: 1),
                reason: "Type name should be between 3 and 40 characters in length: 'A'")))

            let longName = Repeat(count: 60, repeatedValue: "A").joinWithSeparator("")
            XCTAssertFalse(violations("\(kind) \(longName) {}\n")
                .map { $0.ruleDescription.identifier }
                .contains(TypeNameRule.description.identifier))
            let longerName = longName + "A"
            XCTAssertTrue(violations("\(kind) \(longerName) {}\n").contains(
                StyleViolation(
                    ruleDescription: TypeNameRule.description,
                    location: Location(file: nil, line: 1, character: 1),
                    reason: "Type name should be between 3 and 40 characters in length: " +
                    "'\(longerName)'")
                ))
        }
    }

    func testNestedTypeNames() {
        XCTAssertEqual(violations("class Abc {\n    class Def {}\n}\n"), [])
        XCTAssertEqual(violations("class Abc {\n    class def\n}\n"),
            [
                StyleViolation(
                    ruleDescription: TypeNameRule.description,
                    severity: .Error,
                    location: Location(file: nil, line: 2, character: 5),
                    reason: "Type name should start with an uppercase character: 'def'")
            ]
        )
    }

    func testVariableNames() {
        for kind in ["class", "struct"] {
            for varType in ["var", "let"] {
                let characterOffset = 8 + kind.characters.count
                XCTAssertFalse(violations("\(kind) Abc { \(varType) def: Void }\n")
                    .map { $0.ruleDescription.identifier }
                    .contains(VariableNameRule.description.identifier))
                XCTAssertTrue(violations("\(kind) Abc { \(varType) de_: Void }\n").contains(
                    StyleViolation(
                        ruleDescription: VariableNameRule.description,
                        severity: .Error,
                        location: Location(file: nil, line: 1, character: characterOffset),
                        reason: "Variable name should only contain alphanumeric characters: 'de_'")
                    ))
                XCTAssertTrue(violations("\(kind) Abc { \(varType) Def: Void }\n").contains(
                    StyleViolation(
                        ruleDescription: VariableNameRule.description,
                        severity: .Error,
                        location: Location(file: nil, line: 1, character: characterOffset),
                        reason: "Variable name should start with a lowercase character: 'Def'")
                    ))
            }
        }
    }

    func testVariableNameMaxLengths() {
        for kind in ["class", "struct"] {
            for varType in ["var", "let"] {
                let characterOffset = 8 + kind.characters.count
                let longName = Repeat(count: 40, repeatedValue: "d").joinWithSeparator("")
                XCTAssertFalse(violations("\(kind) Abc { \(varType) \(longName): Void }\n")
                    .map { $0.ruleDescription.identifier }
                    .contains(VariableNameMaxLengthRule.description.identifier))
                let longerName = longName + "d"
                XCTAssertTrue(violations("\(kind) Abc { \(varType) \(longerName): Void }\n")
                    .contains(StyleViolation(
                        ruleDescription: VariableNameMaxLengthRule.description,
                        severity: .Warning,
                        location: Location(file: nil, line: 1, character: characterOffset),
                        reason: "Variable name should be 40 characters or less: currently " +
                        "41 characters")
                    ))

                let longestName = Repeat(count: 60, repeatedValue: "d").joinWithSeparator("")
                    + "d"
                XCTAssertTrue(violations("\(kind) Abc { \(varType) \(longestName): Void }\n")
                    .contains(StyleViolation(
                        ruleDescription: VariableNameMaxLengthRule.description,
                        severity: .Error,
                        location: Location(file: nil, line: 1, character: characterOffset),
                        reason: "Variable name should be 60 characters or less: currently " +
                        "61 characters")
                    ))
            }
        }
    }

    func testVariableNameMinLengths() {
        for kind in ["class", "struct"] {
            for varType in ["var", "let"] {
                let characterOffset = 8 + kind.characters.count
                XCTAssertFalse(violations("\(kind) Abc { \(varType) def: Void }\n")
                    .map { $0.ruleDescription.identifier }
                    .contains(VariableNameMinLengthRule.description.identifier))
                XCTAssertTrue(violations("\(kind) Abc { \(varType) d: Void }\n").contains(
                    StyleViolation(
                        ruleDescription: VariableNameMinLengthRule.description,
                        severity: .Error,
                        location: Location(file: nil, line: 1, character: characterOffset),
                        reason: "Variable name should be 2 characters or more: currently " +
                        "1 characters")
                    ))

                XCTAssertTrue(violations("\(kind) Abc { \(varType) de: Void }\n").contains(
                    StyleViolation(
                        ruleDescription: VariableNameMinLengthRule.description,
                        severity: .Warning,
                        location: Location(file: nil, line: 1, character: characterOffset),
                        reason: "Variable name should be 3 characters or more: currently " +
                        "2 characters")
                    ))
            }
        }
    }

    func testFunctionBodyLengths() {
        let longFunctionBody = "func abc() {" +
            Repeat(count: 40, repeatedValue: "\n").joinWithSeparator("") +
            "}\n"
        XCTAssertFalse(violations(longFunctionBody)
            .map { $0.ruleDescription.identifier }
            .contains(FunctionBodyLengthRule.description.identifier))
        let longerFunctionBody = "func abc() {" +
            Repeat(count: 41, repeatedValue: "\n").joinWithSeparator("") +
            "}\n"
        XCTAssertTrue(violations(longerFunctionBody).contains(StyleViolation(
            ruleDescription: FunctionBodyLengthRule.description,
            location: Location(file: nil, line: 1, character: 1),
            reason: "Function body should be span 40 lines or less: currently spans 41 lines")))
    }

    func testTypeBodyLengths() {
        for kind in ["class", "struct", "enum"] {
            let longTypeBody = "\(kind) Abc {" +
                Repeat(count: 200, repeatedValue: "\n").joinWithSeparator("") +
                "}\n"
            XCTAssertFalse(violations(longTypeBody)
                .map { $0.ruleDescription.identifier }
                .contains(TypeBodyLengthRule.description.identifier))
            let longerTypeBody = "\(kind) Abc {" +
                Repeat(count: 201, repeatedValue: "\n").joinWithSeparator("") +
                "}\n"
            XCTAssertTrue(violations(longerTypeBody).contains(StyleViolation(
                ruleDescription: TypeBodyLengthRule.description,
                location: Location(file: nil, line: 1, character: 1),
                reason: "Type body should be span 200 lines or less: currently spans 201 lines")))
        }
    }

    func testTypeNamesVerifyRule() {
        verifyRule(TypeNameRule.description)
    }

    func testVariableNamesVerifyRule() {
        verifyRule(VariableNameRule.description)
    }

    func testVariableNameMaxLengthsVerifyRule() {
        verifyRule(VariableNameMaxLengthRule.description)
    }

    func testVariableNameMinLengthsVerifyRule() {
        verifyRule(VariableNameMinLengthRule.description)
    }

    func testNesting() {
        verifyRule(NestingRule.description)
    }

    func testControlStatements() {
        verifyRule(ControlStatementRule.description)
    }
}
