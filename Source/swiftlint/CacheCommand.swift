//
//  CacheCommand.swift
//  SwiftLint
//
//  Created by Keith Smiley on 8/7/15.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Commandant
import Foundation
import Result
import SourceKittenFramework
import SwiftLintFramework
import SwiftXPC

struct CacheCommand: CommandType {
    let verb = "cache"
    let function = "Cache protocols and their paths"

    func run(mode: CommandMode) -> Result<(), CommandantError<()>> {
        let configuration = Configuration(optional: false)
        if configuration.included.count <= 0 {
            fputs("Caching requires configuration\n", stderr)
            return .Failure(CommandantError<()>.CommandError(()))
        }

        let URL = NSURL(fileURLWithPath: (".protocols_cache.json" as NSString).absolutePathRepresentation())
        let paths = configuration.included.flatMap(filesToLintAtPath)
        self.cache(URL, paths: paths)
        return .Success()
    }

    private func cache(cacheURL: NSURL, paths: [String]) {
        var pathForProtocol = [String: String]()
        if let data = NSData(contentsOfURL: cacheURL),
            let json: AnyObject = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
            let protocols = json as? [String: String]
        {
            pathForProtocol = protocols
        }

        let files = paths.flatMap { File(path: $0) }
        for file in files {
            let protocols = self.protocolsFromFile(file)
            for (k, v) in protocols {
                pathForProtocol[k] = v
            }
        }

        let dictionary = pathForProtocol as NSDictionary
        let JSON = try? NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
        JSON?.writeToURL(cacheURL, atomically: true)
    }

    private func protocolsFromFile(file: File) -> [String: String] {
        let path: String! = file.path
        if path == nil {
            return [:]
        }

        var pathForProtocol = [String: String]()
        if let structure = file.structure.dictionary["key.substructure"] as? XPCArray {
            for element in structure {
                let contents = element as? XPCDictionary ?? [:]
                if !self.isProtocol(contents) {
                    continue
                }

                if let name = contents["key.name"] as? String {
                    pathForProtocol[name] = path
                }
            }
        }

        return pathForProtocol
    }

    private func isProtocol(attributes: XPCDictionary) -> Bool {
        if let kind = attributes["key.kind"] as? String, type = SwiftDeclarationKind(rawValue: kind) {
            return type == .Protocol
        }

        return false
    }
}

private func filesToLintAtPath(path: String) -> [String] {
    let absolutePath = path.absolutePathRepresentation()
    var isDirectory: ObjCBool = false
    if fileManager.fileExistsAtPath(absolutePath, isDirectory: &isDirectory) {
        if isDirectory {
            return fileManager.allFilesRecursively(directory: absolutePath).filter {
                $0.isSwiftFile()
            }
        } else if absolutePath.isSwiftFile() {
            return [absolutePath]
        }
    }

    return []
}
