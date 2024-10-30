//
//  CacheConcurrent.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

private struct ConcurrentSyncCache<
    Concurred: SendableSyncCache
> where Concurred.ID: Sendable, Concurred.Value: Sendable {
    private let concurred: Concurred

    init(concurring cache: Concurred) {
        self.concurred = cache
    }
}

extension ConcurrentSyncCache: AsyncCache {
    func value(for id: Concurred.ID) async -> Concurred.Value? {
        concurred.value(for: id)
    }

    func store(value: Concurred.Value, for id: Concurred.ID) async {
        concurred.store(value: value, for: id)
    }
}

public extension SendableSyncCache where Self: Sendable, ID: Sendable, Value: Sendable {
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
    func concurrent() -> some AsyncCache<ID, Value> {
        ConcurrentSyncCache(concurring: self)
    }
}
