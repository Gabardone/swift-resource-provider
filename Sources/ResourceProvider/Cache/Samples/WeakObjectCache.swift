//
//  WeakObjectCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

/**
 In-memory `weak` reference cache for objects.

 Since `weak` references can only be used for reference types, this cache only accepts those.

 The type is declared synchronous since it's fast and simple enough to be used synchronously, use `serialized` to use in
 a concurrent context.
 */
public struct WeakObjectCache<ID: Hashable, Value: AnyObject> {
    public init() {}

    // MARK: - Stored Properties

    private let weakObjects = NSMapTable<KeyWrapper<ID>, Value>.strongToWeakObjects()
}

extension WeakObjectCache: SyncCache {
    public func value(for id: ID) -> Value? {
        weakObjects.object(forKey: .init(wrapping: id))
    }

    public func store(value: Value, for id: ID) {
        weakObjects.setObject(value, forKey: .init(wrapping: id))
    }
}

/**
 A simple, private wrapper type so value types and reference types that don't inherit from `NSObject` can be used as
 keys for a `NSMapTable`. An implementation detail.
 */
private class KeyWrapper<ID: Hashable>: NSObject, NSCopying {
    func copy(with _: NSZone? = nil) -> Any {
        self
    }

    init(wrapping: ID) {
        self.wrapping = wrapping
    }

    let wrapping: ID

    // Because of `NSMapTable` quaint old ways we have to override the `NSObject` versions for equality.
    override func isEqual(_ other: Any?) -> Bool {
        guard let otherWrapper = other as? Self else {
            return false
        }

        return wrapping == otherWrapper.wrapping
    }

    // Because of `NSMapTable` quaint old ways we have to override the `NSObject` versions for hashing.
    override var hash: Int {
        wrapping.hashValue
    }
}
