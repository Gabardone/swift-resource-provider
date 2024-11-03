//
//  ForceSendable.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/18/24.
//

private struct UncheckedSendableSyncProvider<
    P: SyncProvider
>: SyncProvider, @unchecked Sendable {
    var syncProvider: P

    func value(for id: P.ID) throws(P.Failure) -> P.Value {
        try syncProvider.value(for: id)
    }
}

extension SyncProvider {
    /**
     Forces a non-sendable sync provider into being `Sendable`. Use at your own risk.

     It is a fact of life that we will often need to deal with legacy non-sendable types, or otherwise perform
     non-sendable operations in an "I Know What I'm Doing" way when interacting with older frameworks. This modifier
     force-converts a non-sendable synchronous provider into a sendable one.

     It only runs when both `ID` and `Value` are already `Sendable`, use `mapValue` to achieve that if needed —if it
     involves `@unchecked Sendable` wrappers that's on you, the developer—.
     - Returns: An IKWID `SyncProvider` that has the exact same behavior as the caller but
     */
    func forceSendable() -> some SendableSyncProvider<ID, Value, Failure> {
        UncheckedSendableSyncProvider(syncProvider: self)
    }
}

extension SyncProvider where Self: Sendable {
    /**
     Forces a non-sendable sync provider into being `Sendable`.

     In case you are using `forceSendable` in a generic context —So Meta— this override skips the wrapper when you
     actually apply it to a `SyncProvider` that is already `Sendable`.
     */
    func forceSendable() -> some SendableSyncProvider<ID, Value, Failure> {
        self
    }
}
