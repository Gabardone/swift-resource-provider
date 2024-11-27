//
//  SyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/18/24.
//

public protocol SyncProvider<ID, Value, Failure> {
    associatedtype ID: Hashable

    associatedtype Value

    associatedtype Failure: Error

    func value(for id: ID) throws(Failure) -> Value

    func eraseToAnySyncProvider() -> AnySyncProvider<ID, Value, Failure>
}

public extension SyncProvider {
    func eraseToAnySyncProvider() -> AnySyncProvider<ID, Value, Failure> {
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
        _ source: @escaping (ID) throws(Failure) -> Value
    ) -> some SyncProvider<ID, Value, Failure> {
        AnySyncProvider(valueForID: source)
    }
}