//
//  AnySyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

/**
 Type-erased ``SyncCache``.

 This wrapper value type can be used to build up adapters for actual cache types, build mocks for testing, and makes for
 a good specific type to use for injected ``SyncCache`` stored properties.
 */
public struct AnySyncCache<ID: Hashable, Value> {
    /**
     A type erased cache has its functionality injected as blocks.
     - Parameters:
       - valueForID: Block that implements ``SyncCache.value(for:)``.
       - storeValueForID: Block that implements ``SyncCache.store(value:id:)``.
     */
    public init(
        valueForID: @escaping (ID) -> Value? = { _ in nil },
        storeValueForID: @escaping (Value, ID) -> Void = { _, _ in }
    ) {
        self.valueForID = valueForID
        self.storeValueForID = storeValueForID
    }

    /// Implements ``SyncCache.value(for:)``.
    public let valueForID: (ID) -> Value?

    /// Implements ``SyncCache.store(value:id:)``.
    public let storeValueForID: (Value, ID) -> Void
}

extension AnySyncCache: SyncCache {
    public func value(for id: ID) -> Value? {
        valueForID(id)
    }

    public func store(value: Value, for id: ID) {
        storeValueForID(value, id)
    }

    /// Optimize away the wrapper when requesting erasure of an already erased value.
    public func eraseToAnyCache() -> AnySyncCache<ID, Value> {
        self
    }
}
