//
//  SendableSyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

public typealias SendableSyncCache<I, V> = SyncCache<I, V> & Sendable

extension SyncCache where Self: Sendable {
    public func eraseToAnySendableSyncCache() -> AnySendableSyncCache<ID, Value> {
        AnySendableSyncCache(valueForID: self.value(for:), storeValueForID: self.store(value:for:))
    }
}
