//
//  AnySyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/19/24.
//

public struct AnySyncProvider<ID: Hashable, Value, Failure: Error> {
    public typealias ValueForID = (ID) throws(Failure) -> Value

    public var valueForID: ValueForID

    public init(valueForID: @escaping ValueForID) {
        self.valueForID = valueForID
    }
}

extension AnySyncProvider: SyncProvider {
    public func value(for id: ID) throws(Failure) -> Value {
        try valueForID(id)
    }

    public func eraseToAnySyncProvider() -> AnySyncProvider<ID, Value, Failure> {
        self
    }
}
