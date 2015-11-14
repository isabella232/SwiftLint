//
//  IntegrationTests.swift
//  SwiftLint
//
//  Created by JP Simard on 5/28/15.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework
import SwiftLintFramework
import XCTest

private let customRuleIdentifiers = [
    HeaderCommentRule.description.identifier,
    DocumentationCommentRule.description.identifier,
    ObjcIdentifierRule.description.identifier,
    HeaderCommentRule.description.identifier,
    MultilineClosureArgumentRule.description.identifier,
    BlanklineFunctionRule.description.identifier,
    CaseIndentRule.description.identifier,
]

class IntegrationTests: XCTestCase {
    func testSwiftLintLints() {
        // This is as close as we're ever going to get to a self-hosting linter.
        let fileManager = NSFileManager.defaultManager()
        let directory = ((((__FILE__ as NSString)
            .stringByDeletingLastPathComponent as NSString)
            .stringByDeletingLastPathComponent as NSString)
            .stringByDeletingLastPathComponent as NSString)
            .stringByAppendingPathComponent("Source")
        let allFiles = fileManager.allFilesRecursively(directory: directory)
        let swiftFiles = allFiles.filter { $0.isSwiftFile() }
            .filter { !$0.hasSuffix("DocumentationCommentRule.swift") }
        XCTAssert(swiftFiles.contains(__FILE__), "current file should be included")
        XCTAssertEqual(swiftFiles.flatMap({Linter(file: File(path: $0)!).styleViolations})
            .filter { !customRuleIdentifiers.contains($0.ruleDescription.identifier) }, [])
    }
}
