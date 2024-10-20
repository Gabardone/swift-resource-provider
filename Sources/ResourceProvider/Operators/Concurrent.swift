//
//  Concurrent.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/19/24.
//

public extension SyncProvider where Self: Sendable, ID: Sendable, Value: Sendable {
    /**
     Returns a wrapper for a sync provider that guarantees serialization.

     If a sync provider needs to be used in an `async` context and it doesn't play well with concurrency —usually
     because you want to avoid data races with its state management— you will want to wrap it in one of these.

     - TODO: Talk about required sendability of ID & Value.
     - TODO: Talk about IKWID for making valueForID functionally `@Sendable`
     - Returns: An `async` provider version of the calling `SyncProvider` that runs its calls serially.
     */
    func concurrent() -> AsyncProvider<ID, Value, Failure> {
        return AsyncProvider { id throws(Failure) in
            try valueFor(id: id)
        }
    }
}
