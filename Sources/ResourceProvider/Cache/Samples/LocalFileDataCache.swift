//
//  LocalFileDataCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

import Foundation
import System

/**
 A simple cache type that stores data in a local cache folder in the local type system.

 The cache is hardcoded to `ID == FilePath` and `Value == Data`. You will normally want to convert to/from your
 provider's `ID` and `Value` using `mapID` and `mapValue` respectively.

 The cache is synchronous and it can also can be used safely from a concurrent context.

 Availability limited by `FilePath` API only being declared in later OS versions.
 */
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public struct LocalFileDataCache {
    private let storageDirectory: FilePath

    // Per docs, safe to use multi-threaded as long as there's not a delegate.
    nonisolated(unsafe)
    private let fileManager: FileManager

    /**
     Initialize a local file data cache.

     The files will be created in a directory whose location is determined by `storageIdentifier`. If needed, a file
     manager other than `FileManager.default` can be used.
     - Parameters:
       - storageIdentifier: An identifier that is used to build the directory where the local data files will be stored.
       - fileManager: A `Foundation.FileManager`. Defaults to the… default one.
     */
    private init(storageIdentifier: FilePath, fileManager: FileManager = .default) {
        self.fileManager = fileManager

        // Calculate the storageDirecotry.
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? {
            Provider.logger.warning("""
            User cache directory not found, using temporary directory for local file data cache
            """)
            return fileManager.temporaryDirectory
        }()
        var storagePath = FilePath(cacheDirectory.path)
        storagePath.append(storageIdentifier.components)
        self.storageDirectory = storagePath
    }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension LocalFileDataCache: SendableSyncCache {
    public func value(for id: FilePath) -> Data? {
        fileManager.contents(atPath: storageDirectory.appending(id.components).description)
    }

    public func store(value: Data, for id: FilePath) {
        fileManager.createFile(atPath: storageDirectory.appending(id.components).description, contents: value)
    }
}
