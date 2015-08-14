//
//  CacheCommand.swift
//  SwiftLint
//
//  Created by Keith Smiley on 8/7/15.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Commandant
import Foundation
import LlamaKit
import SourceKittenFramework
import SwiftLintFramework
import SwiftXPC

struct CacheCommand: CommandType {
    let verb = "cache"
    let function = "Cache protocols and their paths"

    func run(mode: CommandMode) -> Result<(), CommandantError<()>> {
        return CacheOptions.evaluate(mode).flatMap { options in
            if let URL = NSURL(fileURLWithPath: options.cachePath) {
                self.cache(URL, directories: options.directories, paths: options.paths)
                return success()
            }

            println("Missing --cachePath argument")
            return failure(CommandantError<()>.CommandError(Box()))
        }
    }

    private func cache(cacheURL: NSURL, directories: [String], paths: [String]) {
        let absoluteDirectories = directories.map { $0.absolutePathRepresentation() }
        var filesToLint = paths.flatMap(filesToLintAtPath)
        var pathForProtocol = [String: String]()

        if let data = NSData(contentsOfURL: cacheURL),
            let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil),
            let protocols = json as? [String: String]
        {
            pathForProtocol = protocols
        } else {
            filesToLint += directories.flatMap(filesToLintAtPath)
        }

        let files = filesToLint.map { File(path: $0) }.filter { $0 != nil }.map { $0! }
        for file in files {
            let protocols = self.protocolsFromFile(file)
            for (k, v) in protocols {
                pathForProtocol[k] = v
            }
        }

        let dictionary = pathForProtocol as NSDictionary
        let JSON = NSJSONSerialization.dataWithJSONObject(dictionary, options: nil, error: nil)
        let worked = JSON?.writeToURL(cacheURL, atomically: true)
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
    let cachePath: String
    let directories: [String]
    let paths: [String]

    static func create(cachePath: String)(directory: String)(path: String) -> CacheOptions {
        let paths = split(path) { $0 == "," }
        let directories = split(directory) { $0 == "," }
        return CacheOptions(cachePath: cachePath, directories: directories, paths: paths)
    }

    private static func evaluate(m: CommandMode) -> Result<CacheOptions, CommandantError<()>> {
        return create
            <*> m <| Option(key: "cachePath", defaultValue: "", usage: "the path to output the cache file")
            <*> m <| Option(key: "directories", defaultValue: "", usage: "the directories to build the cache from separated by commas")
            <*> m <| Option(key: "paths", defaultValue: "", usage: "the path to changed files separated by commas")
    }
}
