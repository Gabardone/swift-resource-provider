//
//  AnySendableSyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

/**
 Type-erased `SyncCache & Sendable`

 This wrapper value type can be used to build up adapters for actual cache types, build mocks for testing, and makes for
 a good specific type to use for non-generic logic to store a ``SyncCache`` that is also `Sendable`, since using
 ``AnySyncCache`` would lose `Sendable` status.

 As a `Sendable` type, it plays more nicely with concurrent types such as ``AsyncCache`` and ``AsyncProvider``.

 Because the Swift type system won't allow us to have conditional adoption of `Sendable` based on function types, we
 need a separate type-erasing type for `SyncCache & Sendable` as opposed to only `SyncCache`.
 */
public struct AnySendableSyncCache<ID: Hashable, Value>: Sendable {
    /**
     A type-erased cache has its functionality injected as blocks.
     - Parameters:
       - valueForID: Implements `SyncCache.value(for:)`. Must be `@Sendable`
       - storeValueForID: Implements `SyncCache.store(value:id:)`. Must be `@Sendable`
     */
    public init(
        valueForID: @escaping @Sendable (ID) -> Value?,
        storeValueForID: @escaping @Sendable (Value, ID) -> Void
    ) {
        self.valueForID = valueForID
        self.storeValueForID = storeValueForID
    }

    /**
     Implements `SyncCache.value(for:)`.

     Must be `@Sendable`. Usually ID and Value will also need to adopt `Sendable` for the compiler to accept it but
     other language options may also work.
     */
    public var valueForID: @Sendable (ID) -> Value?

    /**
     Implements `SyncCache.store(value:id:)`

     Must be `@Sendable`. Usually ID and Value will also need to adopt `Sendable` for the compiler to accept it but
     other language options may also work.
     */
    public var storeValueForID: @Sendable (Value, ID) -> Void
}

extension AnySendableSyncCache: SyncCache {
    public func value(for id: ID) -> Value? {
        valueForID(id)
    }

    public func store(value: Value, for id: ID) {
        storeValueForID(value, id)
    }
}

public extension AnySendableSyncCache {
    /// Optimize away the wrapper when requesting erasure of an already erased value.
    func eraseToAnySendableSyncCache() -> AnySendableSyncCache<ID, Value> {
        self
    }
}
