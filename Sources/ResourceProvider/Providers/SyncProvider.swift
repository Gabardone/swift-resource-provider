//
//  SyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/21/24.
//

/**
 A resouce provider that returns values synchronously.

 A `SyncProvider` doesn't allow for failure in value retrieval, so it's best used for cases where the values are
 generated. Examples of use would be:
 - To manage quick to generate large object (i.e. images) where we want to keep around only the ones we're using, with
 a `WeakObjectCache`.
 - To abstract away old synchronous APIs like AppKit document facilities where we are also limited in being able to make
 things asynchronous.
 */
public struct SyncProvider<ID: Hashable, Value, Failure: Error> {
    /**
     Synchronously returns the value for the given `id`.
     - Parameter ID: The ID for the resource.
     - Returns: The value for the given `ID`
     */
    public var valueForID: (ID) throws(Failure) -> Value
}

public extension Provider {
    /**
     Builds a synchronous provider source.
     - Parameter source: A block that generates values based on a given `ID`.
     - Returns: A synchronous provider that generates its values by running the given block.
     */
    static func source<ID: Hashable, Value, Failure>(
        _ source: @escaping (ID) throws(Failure) -> Value
    ) -> SyncProvider<ID, Value, Failure> {
        SyncProvider(valueForID: source)
    }
}
