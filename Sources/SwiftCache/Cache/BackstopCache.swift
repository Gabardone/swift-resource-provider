//
//  BackstopCache.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

/**
 A configurable chainable cache that retrieves data from its storage.

 This is meant for the end of a cache chain as a final backstop for finding the requested data. Common examples would
 be network-backed values or from other storage that we are not meant to modify.

 Beyond optimizing away simultaneous calls for the same ID this cache does no optimizations, it is therefore unwise to
 use directly without other storage layers in between this and the cache client. Normally a `ChainableCache` or several
 will sit in between with faster and more persistent storage attached.
 */
public actor BackstopCache<Cached, CacheID: Hashable, Stored, StorageID: Hashable> {
    /**
     Initializes with a storage and a full set of injectable behaviors.

     Factory methods are provided for common use cases. This can still be used for custom building a full backstop
     storage cache.
     - Parameter storage: The storage where we will attempt to fetch values from.
     - Parameter idConverter: A block that converts cache IDs to storage IDs for the cache's storage.
     - Parameter fromStorageConverter: A block that converts storage values into cache values.
     */
    public init(
        storage: some ValueSource<Stored, StorageID>,
        idConverter: @escaping IDConverter,
        fromStorageConverter: @escaping FromStorageConverter
    ) {
        self.storage = storage
        self.idConverter = idConverter
        self.fromStorageConverter = fromStorageConverter
    }

    // MARK: - Types

    /**
     Block used to convert cache IDs to storage IDs. Unlike the other injectable behaviors, this is expected to always
     work and do so synchronously.
     */
    public typealias IDConverter = (CacheID) -> StorageID

    /**
     Type of block used to convert from stored values to cache values.
     */
    public typealias FromStorageConverter = (Stored) async throws -> (Cached)

    // MARK: - Stored Properties

    private let storage: any ValueSource<Stored, StorageID>

    private let idConverter: IDConverter

    private let fromStorageConverter: FromStorageConverter

    private var taskManager = [CacheID: Task<Cached?, Error>]()

    // MARK: - Test Properties

    #if DEBUG
    /**
     This block, if set, will be run at the entrypoint of `cachedValueWith(identifier:)`.

     Use it to validate actor reentry and order of operations.

     Purposefully a non-async method as to avoid actor concurrent behavior changes when run, keep in mind that it's run
     in actor context when set.
     */
    var enteredCachedValueWithIdentifier: ((CacheID) async -> Void)?

    func setEnteredCachedValueWithIdentifier(_ block: ((CacheID) async -> Void)?) {
        enteredCachedValueWithIdentifier = block
    }
    #endif
}

// MARK: - Cache Adoption

extension BackstopCache: Cache {
    public typealias Cached = Cached

    public typealias CacheID = CacheID

    public func cachedValueWith(identifier: CacheID) async throws -> Cached? {
        #if DEBUG
        await enteredCachedValueWithIdentifier?(identifier)
        #endif
        if let ongoingTask = taskManager[identifier] {
            // Avoid reentrancy, just wait for the ongoing task that is already doing the stuff.
            return try await ongoingTask.value
        } else {
            let newTask = Task<Cached?, Error> {
                defer {
                    // No matter what happens at the end we want to clear out the task in the manager.
                    taskManager.removeValue(forKey: identifier)
                }

                if let stored = try await storage.valueFor(identifier: idConverter(identifier)) {
                    return try await fromStorageConverter(stored)
                } else {
                    return nil
                }
            }

            taskManager[identifier] = newTask
            return try await newTask.value
        }
    }

    public func invalidateCachedValueFor(identifier _: CacheID) async throws {
        // This method intentionally left blank. The ValueStorage doesn't allow for deletion.
    }
}

// MARK: - Helper Initializers

public extension BackstopCache where CacheID == StorageID {
    init(
        storage: some ValueSource<Stored, StorageID>,
        fromStorageConverter: @escaping FromStorageConverter
    ) {
        self.init(
            storage: storage,
            idConverter: { $0 },
            fromStorageConverter: fromStorageConverter
        )
    }
}

public extension BackstopCache where Cached == Stored {
    init(storage: some ValueSource<Stored, StorageID>, idConverter: @escaping IDConverter) {
        self.init(
            storage: storage,
            idConverter: idConverter,
            fromStorageConverter: { $0 }
        )
    }
}

public extension BackstopCache where CacheID == StorageID, Cached == Stored {
    init(storage: some ValueSource<Stored, StorageID>) {
        self.init(
            storage: storage,
            idConverter: { $0 },
            fromStorageConverter: { $0 }
        )
    }
}
