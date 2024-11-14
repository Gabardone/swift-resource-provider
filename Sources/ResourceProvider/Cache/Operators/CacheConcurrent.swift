//
//  CacheConcurrent.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

private struct ConcurrentSyncCache<
    Concurred: SyncCache & Sendable
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

public extension SyncCache where Self: Sendable, ID: Sendable, Value: Sendable {
    /**
     Returns a wrapper for a (`Sendable`) sync cache that guarantees serialization.

     If a sync cache needs to be used in an `async` context and it plays well with concurrency. you will want to use
     this operator to make it into an ``AsyncCache``.

     The `Sendable` requirement for the caller tells the compiler that it's safe to treat the caller concurrently and in
     general it _will_ be safe unless you just `@unchecked Sendable` or otherwise forced adoption of the marker protocol
     but failed to get the implementation to actually be safe in concurrent use.
     - Returns: An `async` cache version of the calling ``SyncCache`` that runs its calls serially.
     */
    func concurrent() -> some AsyncCache<ID, Value> {
        ConcurrentSyncCache(concurring: self)
    }
}
