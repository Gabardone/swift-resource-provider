//
//  AnyAsyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

/**
 Type-erased ``AsyncCache``.

 This wrapper value type can be used to build up adapters for actual cache types, build mocks for testing, and makes for
 a good specific type to use for injected ``AsyncCache`` stored properties.
 */
public struct AnyAsyncCache<ID: Hashable & Sendable, Value: Sendable> {
    /**
     A type-erased cache has its functionality injected as blocks.
     - Parameters:
       - valueForID: Block that implements ``AsyncCache.value(for:)``.
       - storeValueForID: Block that implements ``AsyncCache.store(value:id:)``.
     */
    public init(
        valueForID: @escaping @Sendable (ID) async -> Value? = { _ in nil },
        storeValueForID: @escaping @Sendable (Value, ID) async -> Void = { _, _ in }
    ) {
        self.valueForID = valueForID
        self.storeValueForID = storeValueForID
    }

    /// Implements `AsyncCache.value(for:)`
    public var valueForID: @Sendable (ID) async -> Value?

    /// Implements `AsyncCache.store(value:id:)`
    public var storeValueForID: @Sendable (Value, ID) async -> Void
}

extension AnyAsyncCache: AsyncCache {
    public func value(for id: ID) async -> Value? {
        await valueForID(id)
    }

    public func store(value: Value, for id: ID) async {
        await storeValueForID(value, id)
    }

    /// Optimize away the wrapper when requesting erasure of an already erased value.
    public func eraseToAnyCache() -> AnyAsyncCache<ID, Value> {
        self
    }
}
