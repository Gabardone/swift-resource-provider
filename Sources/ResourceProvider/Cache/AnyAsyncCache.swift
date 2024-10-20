//
//  AnyAsyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

/**
 Type-erased async cache.

 This wrapper value type can be (and is) used to build up adapters for actual cache types, and can also be used to
 build mocks for testing.
 */
public struct AnyAsyncCache<ID: Hashable, Value> {
    /**
     A type erased cache has its functionality injected as blocks.
     - Parameters:
       - valueForID: Block that implements `AsyncCache.value(for:)`
       - storeValueForID: Block that implements `AsyncCache.store(value:id:)`
     */
    public init(
        valueForID: @escaping (ID) async -> Value? = { _ in nil },
        storeValueForID: @escaping (Value, ID) async -> Void = { _, _ in }
    ) {
        self.valueForID = valueForID
        self.storeValueForID = storeValueForID
    }

    /// Implements `AsyncCache.value(for:)`
    public let valueForID: (ID) async -> Value?

    /// Implements `AsyncCache.store(value:id:)`
    public let storeValueForID: (Value, ID) async -> Void
}

extension AnyAsyncCache: AsyncCache {
    public func value(for id: ID) async -> Value? {
        await valueForID(id)
    }

    public func store(value: Value, id: ID) async {
        await storeValueForID(value, id)
    }

    public func eraseToAnyCache() -> AnyAsyncCache<ID, Value> {
        self
    }
}
