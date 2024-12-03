//
//  MapID.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

// MARK: - SyncProvider Map ID

private struct IDMappingSyncProvider<Mapped: SyncProvider, ID: Hashable>: SyncProvider {
    var mapped: Mapped

    var idMapper: (ID) -> Mapped.ID

    func value(for id: ID) throws(Mapped.Failure) -> Mapped.Value {
        try mapped.value(for: idMapper(id))
    }
}

public extension SyncProvider {
    /**
     Maps an id type to the calling ``SyncProvider`` id type.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling
     ``SyncProvider``.
     - Returns: A ``SyncProvider`` that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(
        _ transform: @escaping (OtherID) -> ID
    ) -> some SyncProvider<OtherID, Value, Failure> {
        IDMappingSyncProvider(mapped: self, idMapper: transform)
    }
}

// MARK: - SyncProvider & Sendable Map ID

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
     Maps an id type to the calling ``SyncProvider`` id type, maintaining sendability.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.

     This is the ``Sendable`` version for easier interaction with ``AsyncCache`` and ``AsyncProvider``. While the
     declaration requires neither `ID` nor `Value` to adopt ``Sendable`` in practice you're unlikely to keep the
     compiler happy unless they aren't.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling
     ``SyncProvider`` `& Sendable`.
     - Returns: A ``SyncProvider`` `& Sendable` that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(
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
     Maps an id type to the calling ``AsyncProvider`` id type.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling
     ``AsyncProvider``.
     - Returns: An ``AsyncProvider`` that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(
        _ transform: @escaping @Sendable (OtherID) -> ID
    ) -> some AsyncProvider<OtherID, Value, Failure> {
        IDMappingAsyncProvider(mapped: self, idMapper: transform)
    }
}
