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
        return CacheOptions.evaluate(mode).flatMap { options in
            let configuration = Configuration(optional: false)
            var paths = [String]()
            if !options.directories.isEmpty {
                paths = options.directories.flatMap(filesToLintAtPath)
            } else if configuration.included.count > 0 {
                paths = configuration.included.flatMap(filesToLintAtPath)
            } else {
                fputs("Caching requires command line arguments or included directories\n", stderr)
                return .Failure(CommandantError<()>.CommandError(()))
            }

            let URL = NSURL(fileURLWithPath: (".protocols_cache.json" as NSString).absolutePathRepresentation())
            self.cache(URL, paths: paths)
            return .Success()
        }
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

private struct CacheOptions: OptionsType {
    let directories: [String]

    static func create(directories: String) -> CacheOptions {
        let directories = directories.characters.split { $0 == "," }.map(String.init)
        return CacheOptions(directories: directories)
    }

    private static func evaluate(m: CommandMode) -> Result<CacheOptions, CommandantError<()>> {
        return create
            <*> m <| Option(key: "directories", defaultValue: "", usage: "the directories to build the cache from separated by commas")
    }
}
