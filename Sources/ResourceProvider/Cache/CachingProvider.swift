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

     Non-`Sendable` sync providers or those using a non-`Sendable` cache will result in a non-`Sendable`
     ``SyncProvider``.
     - Parameter cache: The cache to use to fetch and store values.
     - Returns A ``SyncProvider`` that caches its results in the given `cache`.
     */
    func cache(_ cache: some SyncCache<ID, Value>) -> some SyncProvider<ID, Value, Failure> {
        sideEffect { value, id in
            cache.store(value: value, for: id)
        }
        .interject { id in
            cache.value(for: id)
        }
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Adds sendable sync caching to the calling provider, keeping sendability.

     If both the provider and the cache are `Sendable`, the result also is `Sendable`, making it simpler and safer to
     make into an `AsyncProvider` with a subsequent modifier.
     - Parameter cache: The cache to use to fetch and store values.
     - Returns A ``SyncProvider`` `& Sendable` that caches its results in the given `cache`.
     */
    func cache(_ cache: some SyncCache<ID, Value> & Sendable) -> some SyncProvider<ID, Value, Failure> & Sendable {
        sideEffect { value, id in
            cache.store(value: value, for: id)
        }
        .interject { id in
            cache.value(for: id)
        }
    }
}

public extension AsyncProvider {
    /**
     Adds caching to the calling provider.

     If you want to use a ``SyncCache``, you need to make it into an `AsyncCache`, making it `Sendable` and using
     ``SyncCache.concurrent()``, ``SyncCache.serialized()`` or a custom-built adapter.
     - Parameter cache: The cache to use to fetch and store values.
     - Returns An ``AsyncProvider`` that caches its results in the given `cache`.
     */
    func cache(_ cache: some AsyncCache<ID, Value>) -> some AsyncProvider<ID, Value, Failure> {
        sideEffect { value, id in
            await cache.store(value: value, for: id)
        }
        .interject { id in
            await cache.value(for: id)
        }
    }
}
