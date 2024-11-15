//
//  NSCacheCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 11/14/24.
//

import Foundation

/**
 In-memory reference type cache for objects.

 Yes, the name is pretty stupid.

 `NSCache` doesn't usually do quite what people think it does but it makes for an easy implementation of an in-memory
 cache for reference types. You can use one of these while nothing more sophisticated is needed.

 `NSCache` being also very friendly with concurrent access means there should be no concerns with using one of these to
 cache an `AsyncProvider` as long as both `ID` and `Value` adopt `Sendable` themselves.

 Both key and value types need to be reference types. use ``mapID(_:)`` to wrap up the keys. For values you can use
 wrappers and ``mapValueToStorage(_:fromStorage:)``.

 The type is declared synchronous for flexibility but a ``makeAsync`` method is offered to transition into
 ``AsyncCache``.
 */
public struct NSCacheCache<ID: Hashable & AnyObject, Value: AnyObject> {
    /**
     You can initialize a ``NSCacheCache`` with an existing `NSCache` object.

     Useful for testing purposes and to have access to the cache from elsewhere to optimize certain flows. Not
     recommended in the general case.
     - Parameter preexistingCache: An existing `NSCache` object that will be used as the backing for the cache.
     */
    public init(preexistingCache: NSCache<ID, Value> = .init()) {
        self.nsCache = preexistingCache
    }

    // MARK: - Stored Properties

    // `nonisoldated(unsafe)` since `NSCache` cannot adopt `Sendable` despite being thread-safe for legacy reasons.
    private nonisolated(unsafe) let nsCache: NSCache<ID, Value>
}

extension NSCacheCache: SyncCache {
    public func value(for id: ID) -> Value? {
        nsCache.object(forKey: id)
    }

    public func store(value: Value, for id: ID) {
        nsCache.setObject(value, forKey: id)
    }
}

// We can treat it as `Sendable` if both ID and Value are.
extension NSCacheCache: Sendable where ID: Sendable, Value: Sendable {}

public extension NSCacheCache where Self: Sendable {
    /**
     Returns an ``AsyncCache`` version of the caller.

     A `Sendable` ``NSCacheCache`` can be used as an ``AsyncCache`` concurrently, this adapter means you don't have to
     remember that detail.
     - Returns: An ``AsyncCache`` wrapper around the calling ``NSCacheCache``
     */
    func makeAsync() -> some AsyncCache<ID, Value> {
        concurrent()
    }
}
