//
//  AnySendableSyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

public struct AnySendableSyncCache<ID: Hashable, Value>: Sendable {
    public typealias ValueForID = @Sendable (ID) -> Value?

    public typealias StoreValueForID = @Sendable (Value, ID) -> Void

    public init(valueForID: @escaping ValueForID, storeValueForID: @escaping StoreValueForID) {
        self.valueForID = valueForID
        self.storeValueForID = storeValueForID
    }

    /// Implements `AsyncCache.value(for:)`
    public let valueForID: ValueForID

    /// Implements `AsyncCache.store(value:id:)`
    public let storeValueForID: StoreValueForID
}

extension AnySendableSyncCache: SyncCache {
    public func value(for id: ID) -> Value? {
        valueForID(id)
    }

    public func store(value: Value, for id: ID) {
        storeValueForID(value, id)
    }
}

public extension AnySendableSyncCache {
    func eraseToAnySendableSyncCache() -> AnySendableSyncCache<ID, Value> {
        self
    }
}
