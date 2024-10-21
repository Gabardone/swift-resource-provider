//
//  AnySendableSyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/19/24.
//

public struct AnySendableSyncProvider<ID: Hashable, Value, Failure: Error> {
    public typealias ValueForID = @Sendable (ID) throws(Failure) -> Value

    public var valueForID: ValueForID

    public init(valueForID: @escaping ValueForID) {
        self.valueForID = valueForID
    }
}

extension AnySendableSyncProvider: SyncProvider {
    public func value(for id: ID) throws(Failure) -> Value {
        try valueForID(id)
    }
}

extension AnySendableSyncProvider: Sendable {}

extension SyncProvider where Self: Sendable {
    func eraseToAnySyncProvider() -> AnySendableSyncProvider<ID, Value, Failure> {
        AnySendableSyncProvider { id throws(Failure) in
            try self.value(for: id)
        }
    }
}
