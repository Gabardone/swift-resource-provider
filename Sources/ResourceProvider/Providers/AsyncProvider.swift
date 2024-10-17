//
//  AsyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/21/24.
//

/**
 A resouce provider that returns values asynchronously.

 An `AsyncProvider` doesn't allow for failure in value retrieval, so it's best used for cases where the values are
 generated. Examples of use would be:
 - A provider that generates complex graphics for a given set of parameters (which would be passed in as the `ID`).
 - A provider that catches the results of another one that fetches data from the network and replaces failures with a
 placeholder.
 */
public struct AsyncProvider<ID: Hashable & Sendable, Value: Sendable> {
    /**
     Returns, asynchronously, the value for the given value ID. An `AsyncProvider` is expected to always succeed in
     returning a value, use `ThrowingAsyncResourceProvider` if the operation may fail.
     - Parameter ID: The ID for the resource.
     - Returns: The value for the given `ID`
     */
    public var valueForID: (ID) async -> Value
}

public extension Provider {
    /**
     Builds an asynchronous provider source.
     - Parameter source: A block that generates values based on a given `ID`.
     - Returns: An asynchronous provider that generates its values by running the given block.
     */
    static func source<ID: Hashable, Value>(
        _ source: @escaping (ID) async -> Value
    ) -> AsyncProvider<ID, Value> {
        AsyncProvider(valueForID: source)
    }
}
