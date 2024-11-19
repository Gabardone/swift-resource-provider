//
//  AsyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

/**
 Declares the API for an asynchronous cache.

 The visible API of an asynchronous cache looks basically like an asynchronous dictionary. Besides access being
 asynchronous, the main difference with an actual dictionary is that storing a value does not guarantee that it will be
 there when requested later as the cache is free to clear the value from storage at any point and for any reason. Or to
 not even store it to begin with.

 There is a guarantee however that _if_ a value is returned, it will be the last one that was stored using
 ``store(value:for:)``.
 */
public protocol AsyncCache<ID, Value>: Sendable {
    /// The id type that uniquely identifies cached values. Needs to adopt `Sendable` to work with Swift concurrency.
    associatedtype ID: Hashable & Sendable

    /// The type of value being cached. Needs to adopt `Sendable` to work with Swift concurrency.
    associatedtype Value: Sendable

    /**
     Returns the value for the given `id`, if present.

     The method will return `nil` if the value is not being stored by the cache, either because it was never stored or
     because it was cleared at some point.
     - Parameter id: The id whose potentially cached value we want.
     - Returns: The value for `id`, if currently stored in the cache, or `nil` if not.
     */
    func value(for id: ID) async -> Value?

    /**
     Stores the given value in the cache.

     A cache offers no guarantees whatsoever that the value stored _will_ be returned later but _if_ it is returned
     later it will be the last value passed in this method for the `id`.
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
