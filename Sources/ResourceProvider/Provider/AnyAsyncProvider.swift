//
//  AnyAsyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

public struct AnyAsyncProvider<ID: Hashable, Value, Failure: Error> {
    public typealias ValueForID = @Sendable (ID) async throws(Failure) -> Value

    public var valueForID: ValueForID

    public init(valueForID: @escaping ValueForID) {
        self.valueForID = valueForID
    }
}

extension AnyAsyncProvider: AsyncProvider {
    public func value(for id: ID) async throws(Failure) -> Value {
        try await valueForID(id)
    }

    public func eraseToAnyAsyncProvider() -> AnyAsyncProvider<ID, Value, Failure> {
        self
    }
}
