//
//  AsyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

/**
 Protocol for asynchronous caches to adopt.

 The visible API of a asynchronous cache is basically as an asynchronous dictionary. Besides access being asynchronous,
 the main difference is that storing a value does not guarantee that it will be there when requested later as the cache
 is free to remove the value from storage in-between.
 */
public protocol AsyncCache<ID, Value>: Sendable {
    /// The id type that uniquely identifies cached values.
    associatedtype ID: Hashable & Sendable

    /// The type of value being cached.
    associatedtype Value: Sendable

    /**
     Returns the value for the given `id`, if present.

     The method will return `nil` if the value is not being stored by the cache, either because it was never stored or
     because it was invalidated at some point.
     - Parameter id: The id whose potentially cached value we want.
     - Returns: The value for `id`, if currently stored in the cache, or `nil` if not.
     */
    func value(for id: ID) async -> Value?

    /**
     Stores the given value in the cache.

     A cache offers no guarantees whatsoever that the value stored _will_ be returned later but _if_ it is returned
     later it will be exactly the same value passed in this method.
     - Parameters:
       - value: The value to store.
       - id: ID associated with the value to store.
     */
    func store(value: Value, for id: ID) async

    /**
     Returns a type-erased version of the calling cache.

     If a cache is used independently of providers it may be useful to store as `AnyAsyncCache`, so any built cache will
     need to be type-erased before being stored.

     This method has a default implementation that will only rarely need to be overwritten.
     - Returns: An `AnyAsyncCache` with the same behavior as the caller.
     */
    func eraseToAnyCache() -> AnyAsyncCache<ID, Value>
}

public extension AsyncCache {
    func eraseToAnyCache() -> AnyAsyncCache<ID, Value> {
        AnyAsyncCache { id in
            await value(for: id)
        } storeValueForID: { value, id in
            await store(value: value, for: id)
        }
    }
}
