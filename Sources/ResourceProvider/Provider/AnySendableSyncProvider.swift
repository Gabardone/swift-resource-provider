//
//  AnySendableSyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/19/24.
//

/**
 Type-erased ``SyncProvider`` `& Sendable`

 This wrapper value type can be used to build up adapters for actual provider types, build mocks for testing, and makes
 for a good specific type to use for injected ``SyncProvider`` stored properties. Use this instead of
 ``AnySyncProvider`` to preserve `Sendable` compliance.

 As a `Sendable` type, it plays more nicely with concurrent types such as ``AsyncCache`` and ``AsyncProvider``.

 Because the Swift type system won't allow us to have conditional adoption of `Sendable` based on function types, we
 need a separate type-erasing type for ``SyncProvider`` `& Sendable` as opposed to only ``SyncProvider``.
 */
public struct AnySendableSyncProvider<ID: Hashable, Value, Failure: Error>: Sendable {
    /**
     A type-erased provider has its functionality injected as a block.
     - Parameter valueForID: Implements ``SyncProvider.value(for:)``. Must be `@Sendable`
     */
    public init(valueForID: @escaping @Sendable (ID) throws(Failure) -> Value) {
        self.valueForID = valueForID
    }

    /**
     Implements ``SyncProvider.value(for:)``.

     Must be `@Sendable`. Usually ID and Value will also need to adopt `Sendable` for the compiler to accept it but
     other language options may also work.
     */
    public var valueForID: @Sendable (ID) throws(Failure) -> Value
}

extension AnySendableSyncProvider: SyncProvider {
    public func value(for id: ID) throws(Failure) -> Value {
        try valueForID(id)
    }

    /// Optimize away the wrapper when requesting erasure of an already erased value.
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
