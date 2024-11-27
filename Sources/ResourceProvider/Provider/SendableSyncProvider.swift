//
//  SendableSyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

/**
 `typealias` for a `SyncProvider` that is also `Sendable`.

 You can erase these to `AnySendableSyncProvider` and in general they are much easier to deal with if there's any
 asynchronicity in the fully built provider chain.

 Swift won't let you use this `typealias` in many places, but it's useful for `some SendableSyncProvider<…>`
 as a return type for a generic function.
 */
public typealias SendableSyncProvider<I, V, F> = Sendable & SyncProvider<I, V, F>

public extension SyncProvider where Self: Sendable {
    func eraseToAnySendableSyncProvider() -> AnySendableSyncProvider<ID, Value, Failure> {
        .init(valueForID: value(for:))
    }
}

public extension Provider {
    /**
     Builds an asynchronous provider source.
     - Parameter source: A block that generates values based on a given `ID`.
     - Returns: An asynchronous provider that generates its values by running the given block.
     */
    static func source<ID: Hashable, Value, Failure: Error>(
        _ source: @escaping @Sendable (ID) throws(Failure) -> Value
    ) -> some SendableSyncProvider<ID, Value, Failure> {
        AnySendableSyncProvider(valueForID: source)
    }
}
