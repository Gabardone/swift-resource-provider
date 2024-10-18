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
        serialized.valueFor(id: id)
    }

    func serializedStore(value: Value, id: ID) {
        serialized.store(value: value, id: id)
    }

    init(serializing cache: Serialized) {
        self.serialized = cache
    }
}

extension SyncCacheSerializer: AsyncCache {
    nonisolated
    func valueFor(id: ID) async -> Value? {
        await serializedValueFor(id: id)
    }

    nonisolated
    func store(value: Value, id: ID) async {
        await serializedStore(value: value, id: id)
    }
}

public extension SyncCache where Self: Sendable, ID: Sendable, Value: Sendable {
    /**
     Returns a wrapper for a sync cache that guarantees serialization.

     If a sync cache needs to be used in an `async` context and it doesn't play well with concurrency —usually because
     you want to avoid data races with its state management— you will want to wrap it in one of these before attaching
     to a provider.

     This is not particularly problematic for very fast caches i.e. in-memory ones. Normally you will be using a
     `Dictionary` or similar collection to keep your stored values around and those are both fast and do not play well
     with concurrency.
     - Returns: An `async` cache version of the calling `SyncCache` that runs its calls serially.
     */
    func serialized() -> some AsyncCache<ID, Value> {
        SyncCacheSerializer(serializing: self)
    }
}
