//
//  SyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/18/24.
//

/**
 A resource provider that returns values asynchronously.

 If you are not doing concurrent programming or want to start with a simpler implementation that later gets modified
 into an ``AsyncProvider`` you can use these to make your life easier.

 To better work with concurrency you will usually want to make sure your provider adopts `Sendable`. All of the
 modifiers in the ``ResourceProvider`` module have overloads that maintain sendability if the parameters passed on to
 them allow for it to happen.
 */
public protocol SyncProvider<ID, Value, Failure> {
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
     Returns the value for the given value ID. A ``SyncProvider`` is expected to always succeed in returning a value and
     will `throw` if that is not possible.
     - Parameter ID: The ID for the resource.
     - Returns: The value for the given `ID`
     */
    func value(for id: ID) throws(Failure) -> Value
}

public extension SyncProvider {
    /**
     Returns a type-erased wrapper around the caller, good for injected stored values and other use cases where a
     specific type needs to be declared.
     - Returns: A type-erased wrapper with the same behavior as the caller.
     */
    func eraseToAnyProvider() -> AnySyncProvider<ID, Value, Failure> {
        .init(valueForID: value(for:))
    }
}

public extension SyncProvider where Failure == Never {
    /**
     Subscript for getting values from the provider.

     Swift subscripts cannot `throw` as of Swift 6.0 so this syntactic sugar is only available for non-throwing
     providers.
     - Parameter id: The id whose value we want to fetch.
     */
    subscript(id: ID) -> Value {
        value(for: id)
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     We need a different type eraser to maintain `Sendable` adoption, which means we need a different type erasing
     function.
     - Returns: A type-erased wrapper with the same behavior as the caller which maintains `Sendable` adoption.
     */
    func eraseToAnyProvider() -> AnySendableSyncProvider<ID, Value, Failure> {
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

    /**
     Builds an asynchronous and `Sendable` provider source.
     - Parameter source: A block that generates values based on a given `ID`.
     - Returns: An asynchronous provider that generates its values by running the given block and adopts `Sendable`.
     */
    static func source<ID: Hashable, Value, Failure: Error>(
        _ source: @escaping @Sendable (ID) throws(Failure) -> Value
    ) -> some SyncProvider<ID, Value, Failure> & Sendable {
        AnySendableSyncProvider(valueForID: source)
    }
}
