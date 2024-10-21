//
//  MapID.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

// MARK: - SyncProvider Map ID

private struct IDMappingSyncProvider<Mapped: SyncProvider, ID: Hashable>: SyncProvider {
    typealias IDMapper = (ID) -> Mapped.ID

    var mapped: Mapped

    var idMapper: IDMapper

    func value(for id: ID) throws(Mapped.Failure) -> Mapped.Value {
        try mapped.value(for: idMapper(id))
    }
}

public extension SyncProvider {
    /**
     Maps an id type to the calling provider's id type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods has the id passed in, where you want to get the outside `ID` coming from the earlier provider so
     you can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling provider.
     - Returns: A provider that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(
        _ transform: @escaping (OtherID) -> ID
    ) -> some SyncProvider<OtherID, Value, Failure> {
        IDMappingSyncProvider(mapped: self, idMapper: transform)
    }
}

// MARK: - Sendable SyncProvider Map ID

private struct IDMappingSendableSyncProvider<
    Mapped: SyncProvider & Sendable,
    ID: Hashable
>: SyncProvider, Sendable {
    typealias IDMapper = @Sendable (ID) -> Mapped.ID

    var mapped: Mapped

    var idMapper: IDMapper

    func value(for id: ID) throws(Mapped.Failure) -> Mapped.Value {
        try mapped.value(for: idMapper(id))
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Maps an id type to the calling provider's id type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods has the id passed in, where you want to get the outside `ID` coming from the earlier provider so
     you can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling provider.
     - Returns: A provider that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable & Sendable>(
        _ transform: @escaping @Sendable (OtherID) -> ID
    ) -> some SyncProvider<OtherID, Value, Failure> & Sendable {
        IDMappingSendableSyncProvider(mapped: self, idMapper: transform)
    }
}

// MARK: - AsyncProvider Map ID

private struct IDMappingAsyncProvider<
    Mapped: AsyncProvider,
    ID: Hashable
>: AsyncProvider {
    typealias IDMapper = @Sendable (ID) -> Mapped.ID

    var mapped: Mapped

    var idMapper: IDMapper

    func value(for id: ID) async throws(Mapped.Failure) -> Mapped.Value {
        try await mapped.value(for: idMapper(id))
    }
}

public extension AsyncProvider {
    /**
     Maps an id type to the calling provider's id type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods has the id passed in, where you want to get the outside `ID` coming from the earlier provider so
     you can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling provider.
     - Returns: A provider that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(
        _ transform: @escaping @Sendable (OtherID) -> ID
    ) -> some AsyncProvider<OtherID, Value, Failure> {
        IDMappingAsyncProvider(mapped: self, idMapper: transform)
    }
}
