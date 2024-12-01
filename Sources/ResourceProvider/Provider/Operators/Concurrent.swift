//
//  Concurrent.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/19/24.
//

private struct ConcurrentSyncProvider<P: SyncProvider>: AsyncProvider where P: Sendable {
    let syncProvider: P

    func value(for id: P.ID) async throws(P.Failure) -> P.Value {
        try syncProvider.value(for: id)
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Returns a wrapper for a ``SyncProvider`` `& Sendable` that guarantees serialization.

     If a ``SyncProvider`` needs to be used in an concurrent context and it plays well with reentrancy you will want to
     use this operator to make it into an ``AsyncProvider``.

     While you can sidestep the `Sendable` requirement by using ``forceSendable()`` on a non-`Sendable` ``SyncProvider``
     you should be very sure that it will behave properly in a concurrent context. If you can't guarantee reentrance
     safety use ``serialized()`` instead.
     - Returns: An ``AsyncProvider`` version of the calling ``SyncProvider`` that runs its calls concurrently.
     */
    func concurrent() -> some AsyncProvider<ID, Value, Failure> {
        ConcurrentSyncProvider(syncProvider: self)
    }
}
