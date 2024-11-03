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
     Returns a wrapper for a sync provider that guarantees serialization.

     If a sync provider needs to be used in an `async` context and it doesn't play well with concurrency —usually
     because you want to avoid data races with its state management— you will want to wrap it in one of these.

     - TODO: Talk about required sendability of ID & Value.
     - TODO: Talk about IKWID for making valueForID functionally `@Sendable`
     - Returns: An `async` provider version of the calling `SyncProvider` that runs its calls serially.
     */
    func concurrent() -> some AsyncProvider<ID, Value, Failure> {
        ConcurrentSyncProvider(syncProvider: self)
    }
}
