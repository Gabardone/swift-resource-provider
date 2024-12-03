//
//  CachingProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncProvider {
    /**
     Adds caching to the modified ``SyncProvider``.

     Modifying a Non-`Sendable` ``SyncProvider`` or applying a non-`Sendable` cache to a ``SyncProvider`` `& Sendable`
     will result in a non-`Sendable` ``SyncProvider``.
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

     This overload will be used if a ``SyncProvider`` `& Sendable` is modified to use a ``SyncCache`` `& Sendable`,
     maintaining `Sendable` compliance.
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

     If you want to use a ``SyncCache``, you need to make it into an ``AsyncCache``, and for that you need a
     `Sendable` compliance, then apply a modifier such as ``SyncCache.concurrent()`` or ``SyncCache.serialized()`` or a
     custom-built adapter.
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
