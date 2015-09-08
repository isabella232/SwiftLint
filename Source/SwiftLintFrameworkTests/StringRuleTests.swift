//
//  StringRuleTests.swift
//  SwiftLint
//
//  Created by JP Simard on 5/28/15.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SwiftLintFramework
import XCTest

class StringRuleTests: XCTestCase {
    func testLineLengths() {
        let longLine = Repeat(count: 110, repeatedValue: "/").joinWithSeparator("") + "\n"
        XCTAssertEqual(violations(longLine), [])
        let testCases: [(String, Int, ViolationSeverity)] = [
            ("/", 111, .Warning),
        ]
        for testCase in testCases {
            XCTAssertEqual(violations(testCase.0 + longLine), [StyleViolation(
                ruleDescription: LineLengthRule.description,
                severity: testCase.2,
<<<<<<< HEAD
                location: Location(file: nil, line: 1),
                reason: "Line should be 100 characters or less: currently \(testCase.1) " +
                "characters")])
=======
                reason: "Line should be 110 characters or less: " +
                "currently \(testCase.1) characters")])
>>>>>>> Swift 2.0 updates
        }
    }

    func testTrailingNewlineAtEndOfFile() {
        XCTAssertEqual(violations("//\n"), [])
        XCTAssertEqual(violations(""), [StyleViolation(
            ruleDescription: TrailingNewlineRule.description,
            location: Location(file: nil, line: 1),
            reason: "File should have a single trailing newline")])
        XCTAssertEqual(violations("//\n\n"), [StyleViolation(
            ruleDescription: TrailingNewlineRule.description,
            location: Location(file: nil, line: 2),
            reason: "File should have a single trailing newline")])
    }

    func testFileLengths() {
        XCTAssertEqual(
            violations(Repeat(count: 400, repeatedValue: "//\n").joinWithSeparator("")),
            []
        )
        let testCases: [(String, Int, ViolationSeverity)] = [
            (Repeat(count: 401, repeatedValue: "//\n").joinWithSeparator(""), 401, .Warning),
            (Repeat(count: 1001, repeatedValue: "//\n").joinWithSeparator(""), 1001, .Error)
        ]
        for testCase in testCases {
            XCTAssertEqual(violations(testCase.0), [StyleViolation(
                ruleDescription: FileLengthRule.description,
                severity: testCase.2,
                location: Location(file: nil, line: testCase.1),
                reason: "File should contain 400 lines or less: currently contains \(testCase.1)")])
        }
    }

    func testFileShouldntStartWithWhitespace() {
        verifyRule(LeadingWhitespaceRule.description, commentDoesntViolate: false)
    }

    func testLinesShouldntContainTrailingWhitespace() {
        verifyRule(TrailingWhitespaceRule.description, commentDoesntViolate: false)
    }

    func testLinesShouldContainReturnArrowWhitespace() {
        verifyRule(ReturnArrowWhitespaceRule.description)
    }

    func testForceCasting() {
        verifyRule(ForceCastRule.description)
    }

    func testOperatorFunctionWhitespace() {
        verifyRule(OperatorFunctionWhitespaceRule.description)
    }

    func testTodoOrFIXME() {
        verifyRule(TodoRule.description, commentDoesntViolate: false)
    }

    func testColon() {
        verifyRule(ColonRule.description)
    }

    func testOpeningBrace() {
        verifyRule(OpeningBraceRule.description)
	}

    func testComma() {
        verifyRule(CommaRule.description)
    }

    func testStatementPosition() {
        verifyRule(StatementPositionRule.description)
    }

    func testDocumentationComments() {
        verifyRule(DocumentationCommentRule(), type: .DocumentationComment, commentDoesntViolate: false)
    }

    func testHeaderComments() {
        verifyRule(HeaderCommentRule(), type: .HeaderComment, commentDoesntViolate: false)
    }

    func testObjcIdentifier() {
        verifyRule(ObjcIdentifierRule(), type: .ObjcIdentifier, commentDoesntViolate: false)
    }

    func testBlanklineFunction() {
        verifyRule(BlanklineFunctionRule(), type: .BlanklineFunction, commentDoesntViolate: false)
    }

    func testMultilineClosureArgument() {
        verifyRule(MultilineClosureArgumentRule(),
            type: .MultilineClosureArgument,
            commentDoesntViolate: false)
    }
}
