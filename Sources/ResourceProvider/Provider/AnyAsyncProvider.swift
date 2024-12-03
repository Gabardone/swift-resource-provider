//
//  AnyAsyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

/**
 Type-erased ``AsyncProvider``.

 This wrapper value type can be used to build up adapters for actual provider types, build mocks for testing, and makes
 for a good specific type to use for injected ``AsyncProvider`` stored properties.
 */
public struct AnyAsyncProvider<ID: Hashable, Value, Failure: Error> {
    /**
     A type-erased provider has its functionality injected as a block.
     - Parameter valueForID: Block that implements ``AsyncProvider.value(for:)``.
     */
    public init(valueForID: @escaping @Sendable (ID) async throws(Failure) -> Value) {
        self.valueForID = valueForID
    }

    /// Implements ``AsyncProvider.value(for:)``.
    public var valueForID: @Sendable (ID) async throws(Failure) -> Value
}

extension AnyAsyncProvider: AsyncProvider {
    public func value(for id: ID) async throws(Failure) -> Value {
        try await valueForID(id)
    }

    /// Optimize away the wrapper when requesting erasure of an already erased value.
    public func eraseToAnyAsyncProvider() -> AnyAsyncProvider<ID, Value, Failure> {
        self
    }
}
