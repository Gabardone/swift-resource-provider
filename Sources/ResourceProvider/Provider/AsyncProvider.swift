//
//  AsyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/21/24.
//

/**
 A resource provider that returns values asynchronously.

 Most resource providers that access the network, or those that require heavy processing or large local file access will
 usually be of this type.

 While this protocol needn't declare itself as `Sendable` from a semantic point of view, there are too many limitations
 to its adoption and the implementation of most of their common modifiers that it doesn't make sense not to.

 Both `ID` and `Value` will usually need to adopt `Sendable` as well as otherwise the compiler will start putting too
 many barriers on your way.

 For providers that generate their values you can often avoid unnecessary `await`s and simplify implementation by using
 a ``SyncProvider`` source and only making it an asynchronous provider near the calling end.
 */
public protocol AsyncProvider<ID, Value, Failure>: Sendable {
    /**
     Identifies values uniquely. The value for a given ID should be stable, the same result if called multiple times
     for the same `ID`.
     */
    associatedtype ID: Hashable

    /// The type of the values returned by the resource provider when it completes a request successfully.
    associatedtype Value

    /**
     The type of `Error` thrown when the provider fails to return a value for a given `ID`. If it is `Never`, the
     provider does not `throw`.
     */
    associatedtype Failure: Error

    /**
     Returns, asynchronously, the value for the given value ID. An ``AsyncProvider`` is expected to always succeed in
     returning a value and will `throw` if that is not possible.
     - Parameter ID: The ID for the resource.
     - Returns: The value for the given `ID`
     */
    func value(for id: ID) async throws(Failure) -> Value
}

public extension AsyncProvider {
    /**
     Returns a type-erased wrapper around the caller, good for injected stored values and other use cases where a
     specific type needs to be declared.
     - Returns: A type-erased wrapper with the same behavior as the caller.
     */
    func eraseToAnyProvider() -> AnyAsyncProvider<ID, Value, Failure> {
        AnyAsyncProvider(valueForID: value(for:))
    }
}

public extension Provider {
    /**
     Builds an asynchronous provider source.
     - Parameter source: A block that generates values based on a given `ID`.
     - Returns: An ``AsyncProvider`` that generates or fetches its values by running the given block.
     */
    static func source<ID: Hashable, Value, Failure: Error>(
        _ source: @escaping @Sendable (ID) async throws(Failure) -> Value
    ) -> some AsyncProvider<ID, Value, Failure> {
        AnyAsyncProvider(valueForID: source)
    }
}
