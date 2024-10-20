//
//  CacheMapID.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

public extension SyncCache {
    /**
     Maps an id type to the calling cache's id type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling cache.
     - Returns: A cache that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some SyncCache<OtherID, Value> {
        AnySyncCache { id in
            value(for: transform(id))
        } storeValueForID: { value, id in
            store(value: value, id: transform(id))
        }
    }
}

public extension AsyncCache {
    /**
     Maps an id type to the calling cache's id type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling cache.
     - Returns: A cache that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some AsyncCache<OtherID, Value> {
        AnyAsyncCache { id in
            await value(for: transform(id))
        } storeValueForID: { value, id in
            await store(value: value, id: transform(id))
        }
    }
}
