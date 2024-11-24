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
     Returns a wrapper for a ``SyncCache`` `& Sendable` that guarantees serialization.

     If a sync cache needs to be used in an concurrent context, it can be moved between execution contexts (`Sendable`)
     and it plays well with reentrancy you will want to use this operator to make it into an ``AsyncCache``.

     While you can sidestep the `Sendable` requirement by using ``forceSendable()-424bn`` on a non-`Sendable`
     ``SyncCache`` you should be very sure that it will behave properly in a concurrent context. If you can't guarantee
     reentrance safety use ``serialized()`` instead.
     - Returns: An ``AsyncCache`` version of the calling ``SyncCache`` that runs its calls concurrently.
     */
    func concurrent() -> some AsyncCache<ID, Value> {
        ConcurrentSyncCache(concurring: self)
    }
}
