//
//  SendableSyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

public protocol SendableSyncProvider<ID, Value, Failure>: SyncProvider, Sendable {
    func eraseToAnySendableSyncProvider() -> AnySendableSyncProvider<ID, Value, Failure>
}

public extension SendableSyncProvider {
    func eraseToAnySendableSyncProvider() -> AnySendableSyncProvider<ID, Value, Failure> {
        .init(valueForID: self.value(for:))
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
