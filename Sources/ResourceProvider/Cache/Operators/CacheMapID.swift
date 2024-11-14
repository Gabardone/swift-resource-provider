//
//  CacheMapID.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

private struct IDMappedSyncCache<Mapped: SyncCache, ID: Hashable> {
    var idMapped: Mapped

    var idTransform: (ID) -> Mapped.ID
}

extension IDMappedSyncCache: SyncCache {
    func value(for id: ID) -> Mapped.Value? {
        idMapped.value(for: idTransform(id))
    }

    func store(value: Mapped.Value, for id: ID) {
        idMapped.store(value: value, for: idTransform(id))
    }
}

public extension SyncCache {
    /**
     Maps an id type to the calling cache's id type.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling cache.
     - Returns: A cache that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some SyncCache<OtherID, Value> {
        IDMappedSyncCache(idMapped: self, idTransform: transform)
    }
}

private struct IDMappedSendableSyncCache<Mapped: SyncCache & Sendable, ID: Hashable>: Sendable {
    var idMapped: Mapped

    var idTransform: @Sendable (ID) -> Mapped.ID
}

extension IDMappedSendableSyncCache: SyncCache {
    func value(for id: ID) -> Mapped.Value? {
        idMapped.value(for: idTransform(id))
    }

    func store(value: Mapped.Value, for id: ID) {
        idMapped.store(value: value, for: idTransform(id))
    }
}

public extension SyncCache where Self: Sendable {
    /**
     Maps an id type to the calling cache's id type.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.

     This is the ``Sendable`` version for easier interaction with ``AsyncCache`` and ``AsyncProvider``. While the
     declaration requires neither `ID` nor `Value` to adopt ``Sendable`` in practice you're unlikely to keep the
     compiler happy unless they aren't.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling cache.
     - Returns: A `Sendable` sync cache that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(
        _ transform: @escaping @Sendable (OtherID) -> ID
    ) -> some SyncCache<OtherID, Value> & Sendable {
        IDMappedSendableSyncCache(idMapped: self, idTransform: transform)
    }
}

private struct IDMappedAsyncCache<Mapped: AsyncCache, ID: Hashable & Sendable> {
    var idMapped: Mapped

    var idTransform: @Sendable (ID) -> Mapped.ID
}

extension IDMappedAsyncCache: AsyncCache {
    func value(for id: ID) async -> Mapped.Value? {
        await idMapped.value(for: idTransform(id))
    }

    func store(value: Mapped.Value, for id: ID) async {
        await idMapped.store(value: value, for: idTransform(id))
    }
}

public extension AsyncCache {
    /**
     Maps an id type to the calling async cache's id type.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling cache.
     - Returns: A cache that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable & Sendable>(
        _ transform: @escaping @Sendable (OtherID) -> ID
    ) -> some AsyncCache<OtherID, Value> {
        IDMappedAsyncCache(idMapped: self, idTransform: transform)
    }
}
