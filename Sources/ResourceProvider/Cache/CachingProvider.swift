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
    func cache(_ cache: some SyncCache<ID, Value>) -> SyncProvider {
        sideEffect { value, id in
            cache.store(value: value, id: id)
        }
        .interject { id in
            cache.value(for: id)
        }
    }

    /**
     Adds caching to the calling provider.

     Adding an asynchronous cache to a synchronous provider turns the provider asynchronous.
     - Parameter cache: The cache to use to fetch and store values.
     */
    func cache(_ cache: some AsyncCache<ID, Value>) -> AsyncProvider<ID, Value> {
        sideEffect { value, id in
            await cache.store(value: value, id: id)
        }
        .interject { id in
            await cache.value(for: id)
        }
    }
}

public extension ThrowingSyncProvider {
    /**
     Adds caching to the calling provider.

     Adding a synchronous cache to a synchronous provider leaves the result synchronous.
     - Parameter cache: The cache to use to fetch and store values.
     */
    func cache(_ cache: some SyncCache<ID, Value>) -> ThrowingSyncProvider {
        sideEffect { value, id in
            cache.store(value: value, id: id)
        }
        .interject { id in
            cache.value(for: id)
        }
    }

    /**
     Adds caching to the calling provider.

     Adding an asynchronous cache to a synchronous provider turns the provider asynchronous.
     - Parameter cache: The cache to use to fetch and store values.
     */
    func cache(_ cache: some AsyncCache<ID, Value>) -> ThrowingAsyncProvider<ID, Value> {
        sideEffect { value, id in
            await cache.store(value: value, id: id)
        }
        .interject { id in
            await cache.value(for: id)
        }
    }
}

public extension AsyncProvider {
    /**
     Adds caching to the calling provider.
     - Parameter cache: The cache to use to fetch and store values.
     */
    func cache(_ cache: some SyncCache<ID, Value>) -> AsyncProvider {
        sideEffect { value, id in
            cache.store(value: value, id: id)
        }
        .interject { id in
            cache.value(for: id)
        }
    }

    /**
     Adds caching to the calling provider.
     - Parameter cache: The cache to use to fetch and store values.
     */
    func cache(_ cache: some AsyncCache<ID, Value>) -> AsyncProvider {
        sideEffect { value, id in
            await cache.store(value: value, id: id)
        }
        .interject { id in
            await cache.value(for: id)
        }
    }
}

public extension ThrowingAsyncProvider {
    /**
     Adds caching to the calling provider.
     - Parameter cache: The cache to use to fetch and store values.
     */
    func cache(_ cache: some SyncCache<ID, Value>) -> ThrowingAsyncProvider {
        sideEffect { value, id in
            cache.store(value: value, id: id)
        }
        .interject { id in
            cache.value(for: id)
        }
    }

    /**
     Adds caching to the calling provider.
     - Parameter cache: The cache to use to fetch and store values.
     */
    func cache(_ cache: some AsyncCache<ID, Value>) -> ThrowingAsyncProvider {
        sideEffect { value, id in
            await cache.store(value: value, id: id)
        }
        .interject { id in
            await cache.value(for: id)
        }
    }
}
