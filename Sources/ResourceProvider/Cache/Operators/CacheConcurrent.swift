//
//  CacheConcurrent.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

private struct ConcurrentSyncCache<C: SyncCache & Sendable> where C.ID: Sendable, C.Value: Sendable {
    let syncCache: C
}

extension ConcurrentSyncCache: AsyncCache {
    func value(for id: C.ID) async -> C.Value? {
        syncCache.value(for: id)
    }

    func store(value: C.Value, for id: C.ID) async {
        syncCache.store(value: value, for: id)
    }
}
