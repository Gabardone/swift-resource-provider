//
//  CacheForceSendable.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

private struct UncheckedSendableSyncCache<C: SyncCache>: @unchecked Sendable {
    var syncCache: C
}

extension UncheckedSendableSyncCache: SyncCache {
    func value(for id: C.ID) -> C.Value? {
        syncCache.value(for: id)
    }

    func store(value: Value, for id: ID) {
        syncCache.store(value: value, for: id)
    }
}

public extension SyncCache {
    /**
     Forces a non-sendable ``SyncCache`` into being `Sendable`. Use at your own risk.

     It is a fact of life that we will often need to deal with legacy non-sendable types, or otherwise perform
     non-sendable operations in an "I Know What I'm Doing" way when interacting with older frameworks. This modifier
     force-converts a non-sendable synchronous cache into a sendable one, usually so you can apply ``concurrent()``
     or ``serialized()`` to it afterwards.

     The modifier can only be applied when both `ID` and `Value` are already `Sendable`. Use ``mapID(_:)-ughf`` and
     ``mapValueToStorage(_:fromStorage:)-23pui`` to achieve either if needed —if it involves `@unchecked Sendable`
     wrappers that's on you, the developer—.
     - Returns: An IKWID `SyncProvider` that has the exact same behavior as the caller but is seen by the compiler as
     `Sendable`
     */
    func forceSendable() -> some SyncCache<ID, Value> & Sendable {
        UncheckedSendableSyncCache(syncCache: self)
    }
}

public extension SyncCache where Self: Sendable {
    /**
     Forces a non-sendable ``SyncCache`` into being `Sendable`.

     In case you are using ``forceSendable`` in a generic context —So Meta— this override skips the wrapper when you
     actually apply it to a ``SyncProvider`` that is already `Sendable`.
     - Returns: Itself.
     */
    func forceSendable() -> some SyncCache<ID, Value> & Sendable {
        self
    }
}
