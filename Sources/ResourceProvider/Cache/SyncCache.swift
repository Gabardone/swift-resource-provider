//
//  SyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

/**
 Declares the API for a synchronous cache.

 The visible API of an asynchronous cache looks basically like a dictionary. The main difference with an actual
 dictionary being that storing a value does not guarantee that it will be there when requested later as the cache is
 free to clear the value from storage at any point and for any reason. Or to not even store it to begin with.

 There is a guarantee however that _if_ a value is returned, it will be the last one that was stored using
 ``store(value:for:)``.

 To make a ``SyncCache`` interact with asynchronous components (either ``AsyncCache`` or ``AsyncProvider``) they must
 be `Sendable` and adapted into ``AsyncCache``. See ``concurrent()`` and ``serialized()`` for the two most common
 async adapters, as well as ``forceSendable()-424bn`` to make a non-`Sendable` ``SyncCache`` into a `Sendable` one —it's
 up to the developer to ensure treating the ``SyncCache`` as `Sendable` is safe.
 */
public protocol SyncCache<ID, Value> {
    /// The id type that uniquely identifies cached values.
    associatedtype ID: Hashable

    /// The type of value being cached.
    associatedtype Value

    /**
     Returns the value for the given `id`, if present.

     The method will return `nil` if the value is not being stored by the cache, whether because it was never stored or
     because it was cleared at some point.
     - Parameter id: The id whose potentially cached value we want.
     - Returns: The value for `id`, if currently stored in the cache, or `nil` if not.
     */
    func value(for id: ID) -> Value?

    /**
     Stores the given value in the cache.

     A cache offers no guarantees whatsoever that the value stored _will_ be returned later —or even stored altogether—
     but _if_ a value is returned later it will be exactly the same value last passed in this method for the given `id`.
     - Parameters:
       - value: The value to store.
       - id: Id associated with the value to store.
     */
    func store(value: Value, for id: ID)

    /**
     Returns a type-erased version of the calling cache.

     If a cache is used independently of providers it may be useful to store as `AnySyncCache`, so any built cache will
     need to be type-erased before being stored.

     This method has a default implementation that will only rarely need to be overwritten.

     If you need your ``SyncCache`` to interact with concurrent logic make sure you adopt `Sendable` and use
     ``eraseToAnySendableSyncCache()`` instead.
     - Returns: An ``AnySyncCache`` with the same behavior as the caller.
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
        value(for: id)
    }

    /// Default implementation of ``eraseToAnyCache()-2vnzt``
    func eraseToAnyCache() -> AnySyncCache<ID, Value> {
        AnySyncCache { id in
            value(for: id)
        } storeValueForID: { value, id in
            store(value: value, for: id)
        }
    }
}

public extension SyncCache where Self: Sendable {
    /**
     Returns a type-erased version of the calling cache that maintains `Sendable` adoption.

     If a cache is used independently of providers it may be useful to store as `AnySyncCache`, so any built cache will
     need to be type-erased before being stored.

     This method has a default implementation that will only rarely need to be overwritten.
     - Returns: An ``AnySendableSyncCache`` with the same behavior as the caller.
     */
    func eraseToAnySendableSyncCache() -> AnySendableSyncCache<ID, Value> {
        AnySendableSyncCache(valueForID: value(for:), storeValueForID: store(value:for:))
    }
}
