//
//  SendableSyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

public protocol SendableSyncCache<ID, Value>: SyncCache, Sendable {
    func eraseToAnySendableSyncCache() -> AnySendableSyncCache<ID, Value>
}

extension SendableSyncCache {
    public func eraseToAnySendableSyncCache() -> AnySendableSyncCache<ID, Value> {
        AnySendableSyncCache(valueForID: self.value(for:), storeValueForID: self.store(value:for:))
    }
}
