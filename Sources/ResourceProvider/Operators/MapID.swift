//
//  MapID.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

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
        AnySyncProvider { otherID throws(Failure) in
            try valueFor(id: transform(otherID))
        }
    }
}

public extension SyncProvider where Self: Sendable, Value: Sendable {
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
        AnySendableSyncProvider { otherID throws(Failure) in
            try valueFor(id: transform(otherID))
        }
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
        _ transform: @Sendable @escaping (OtherID) -> ID
    ) -> AsyncProvider<OtherID, Value, Failure> {
        .init { otherID throws(Failure) in
            try await valueForID(transform(otherID))
        }
    }
}
