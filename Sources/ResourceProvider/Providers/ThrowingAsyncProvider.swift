//
//  ThrowingAsyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/21/24.
//

/**
 A resouce provider that returns values asynchronously and may fail.

 A `ThrowingAsyncProvider` will `throw` if value retrieval fails. It vends the most complete API and as such is used for
 the more complex resource providers such as:
 - Resource download from the network.
 - Complex database retrieval.
 */
public struct ThrowingAsyncProvider<ID: Hashable & Sendable, Value: Sendable> {
    /**
     Returns, asynchronously, the value for the given ID. A `ThrowingAsyncProvider` will throw if it fails to return a
     value. In that case, the implementation should ensure that the operations leaves no side effects in the provider's
     state and a subsequent call to the provider for the same `ID` will run the same logic again.
     - Parameter ID: The ID for the resource.
     - Returns: The value for the given `ID`
     */
    public var valueForID: (ID) async throws -> Value
}

public extension Provider {
    /**
     Builds a throwing asynchronous provider source.
     - Parameter source: A block that generates values based on a given `ID`, or throws if it cannot.
     - Returns: An asynchronous provider that generates its values by running the given block.
     */
    static func source<ID: Hashable, Value>(
        _ source: @escaping (ID) async throws -> Value
    ) -> ThrowingAsyncProvider<ID, Value> {
        .init(valueForID: source)
    }
}
