//
//  AnySendableSyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/19/24.
//

/**
 Type-erased `SyncProvider & Sendable`

 `AnySyncProvider` cannot be given conditional conformance to `Sendable` due to functions not being first class citizens
 in Swift, which leaves us with no support for the compiler logic we would need to establish the condition for
 conforming.

 Basically if the type-erasing block is `@Sendable` you can build an `AnySendableSyncProvider`. This usually will also
 require that both `ID` and `Value` are either `Sendable` or `sending`. The latter option can be a bit glitchy as of
 Swift 6.0.
 */
public struct AnySendableSyncProvider<ID: Hashable, Value, Failure: Error>: Sendable {
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

    public func eraseToAnySendableSyncProvider() -> AnySendableSyncProvider<ID, Value, Failure> {
        self
    }
}

extension AnySendableSyncProvider {
    func eraseToAnySyncProvider() -> AnySendableSyncProvider<ID, Value, Failure> {
        AnySendableSyncProvider { id throws(Failure) in
            try self.value(for: id)
        }
    }
}
