//
//  CacheSerialized.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/1/24.
//

private actor SyncCacheSerializer<
    ID: Hashable & Sendable,
    Value: Sendable,
    Serialized: SyncCache
> where Serialized.ID == ID, Serialized.Value == Value {
    private let serialized: Serialized

    func serializedValueFor(id: ID) -> Value? {
        serialized.value(for: id)
    }

    func serializedStore(value: Value, for id: ID) {
        serialized.store(value: value, for: id)
    }

    init(serializing cache: Serialized) {
        self.serialized = cache
    }
}

extension SyncCacheSerializer: AsyncCache {
    nonisolated
    func value(for id: ID) async -> Value? {
        await serializedValueFor(id: id)
    }

    nonisolated
    func store(value: Value, for id: ID) async {
        await serializedStore(value: value, for: id)
    }
}

public extension SendableSyncCache where ID: Sendable, Value: Sendable {
    /**
     Returns a wrapper for a sync cache that guarantees serialization.

     If a sync cache needs to be used in an `async` context and it doesn't play well with concurrency —usually because
     you want to avoid data races with its state management— you will want to wrap it in one of these before attaching
     to a provider.

     This is not particularly problematic for very fast caches i.e. in-memory ones. Normally you will be using a
     `Dictionary` or similar collection to keep your stored values around and those are both fast and do not play well
     with concurrency.
     - Note: Value must be `Sendable` because of Swift 6.0 weirdness. Likely to be relaxed in Swift 6.1
     - Returns: An `async` cache version of the calling `SyncCache` that runs its calls serially.
     */
    func serialized() -> some AsyncCache<ID, Value> {
        SyncCacheSerializer(serializing: self)
    }
}
