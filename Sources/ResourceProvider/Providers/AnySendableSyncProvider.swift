//
//  AnySendableSyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/19/24.
//

public struct AnySendableSyncProvider<ID: Hashable & Sendable, Value: Sendable, Failure: Error> {
    public typealias ValueForID = @Sendable (ID) throws(Failure) -> Value

    public var valueForID: ValueForID

    public init(valueForID: @escaping ValueForID) {
        self.valueForID = valueForID
    }
}

extension AnySendableSyncProvider: SyncProvider {
    public func valueFor(id: ID) throws(Failure) -> Value {
        try valueForID(id)
    }
}

extension AnySendableSyncProvider: Sendable {}
