//
//  SyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

/**
 Protocol for synchronous caches to adopt.

 The visible API of a synchronous cache is basically as a `Dictionary`. The difference is that storing a value does not
 guarantee that it will be there when requested later as the cache is free to remove the value from storage in-between.
 */
public protocol SyncCache<ID, Value> {
    /// The id type that uniquely identifies cached values.
    associatedtype ID: Hashable

    /// The type of value being cached.
    associatedtype Value

    /**
     Returns the value for the given `id`, if present.

     The method will return `nil` if the value is not being stored by the cache, whether because it was never stored or
     because it was invalidated at some point.
     - Parameter id: The id whose potentially cached value we want.
     - Returns: The value for `id`, if currently stored in the cache, or `nil` if not.
     */
    func valueFor(id: ID) -> Value?

    /**
     Stores the given value in the cache.

     A cache offers no guarantees whatsoever that the value stored _will_ be returned later but _if_ it is returned
     later it will be exactly the same value passed in this method.
     - Parameters:
       - value: The value to store.
       - id: Id associated with the value to store.
     */
    func store(value: Value, id: ID)

    /**
     Returns a type-erased version of the calling cache.

     If a cache is used independently of providers it may be useful to store as `AnySyncCache`, so any built cache will
     need to be type-erased before being stored.

     This method has a default implementation that will only rarely need to be overwritten.
     - Returns: An `AnySyncCache` with the same behavior as the caller.
     */
    func eraseToAnyCache() -> AnySyncCache<ID, Value>
}

public extension SyncCache {
    /**
     Subscript for reading cache values.

     The subscript won't allow for writing since we don't want to accept `nil` for `store(value:id:)`
     - Parameter id: The id whose potential value we want to fetch.
     */
    subscript(id: ID) -> Value? {
        valueFor(id: id)
    }

    func eraseToAnyCache() -> AnySyncCache<ID, Value> {
        AnySyncCache { id in
            valueFor(id: id)
        } storeValueForID: { value, id in
            store(value: value, id: id)
        }
    }
}
