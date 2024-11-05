//
//  SendableSyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

public typealias SendableSyncCache<I, V> = Sendable & SyncCache<I, V>

public extension SyncCache where Self: Sendable {
    func eraseToAnySendableSyncCache() -> AnySendableSyncCache<ID, Value> {
        AnySendableSyncCache(valueForID: value(for:), storeValueForID: store(value:for:))
    }
}
