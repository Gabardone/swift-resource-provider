//
//  AnySyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/19/24.
//

/**
 Type-erased ``SyncProvider``.

 This wrapper value type can be used to build up adapters for actual provider types, build mocks for testing, and makes
 for a good specific type to use for injected ``SyncProvider`` stored properties.
 */
public struct AnySyncProvider<ID: Hashable, Value, Failure: Error> {
    /**
     A type erased provider has its functionality injected as a block.
     - Parameter valueForID: Block that implements ``SyncProvider.value(for:)``.
     */
    public init(valueForID: @escaping (ID) throws(Failure) -> Value) {
        self.valueForID = valueForID
    }

    /// Implements ``SyncProvider.value(for:)``.
    public var valueForID: (ID) throws(Failure) -> Value
}

extension AnySyncProvider: SyncProvider {
    public func value(for id: ID) throws(Failure) -> Value {
        try valueForID(id)
    }

    /// Optimize away the wrapper when requesting erasure of an already erased value.
    public func eraseToAnySyncProvider() -> AnySyncProvider<ID, Value, Failure> {
        self
    }
}
