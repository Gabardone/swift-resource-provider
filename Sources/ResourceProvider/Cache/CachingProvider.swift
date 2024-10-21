//
//  CachingProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncProvider {
    /**
     Adds caching to the calling provider.

     Adding a synchronous cache to a synchronous provider leaves the result synchronous.
     - Parameter cache: The cache to use to fetch and store values.
     */
    func cache(_ cache: some SyncCache<ID, Value>) -> some SyncProvider<ID, Value, Failure> {
        sideEffect { value, id in
            cache.store(value: value, id: id)
        }
        .interject { id in
            cache.valueFor(id: id)
        }
    }
}

public extension AsyncProvider {
    /**
     Adds caching to the calling provider.
     - Parameter cache: The cache to use to fetch and store values.
     */
    func cache(_ cache: some AsyncCache<ID, Value>) -> some AsyncProvider<ID, Value, Failure> {
        sideEffect { value, id in
            await cache.store(value: value, id: id)
        }
        .interject { id in
            await cache.valueFor(id: id)
        }
    }
}
