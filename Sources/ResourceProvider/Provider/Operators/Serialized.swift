//
//  Serialized.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

import Foundation

private actor SyncProviderSerializer<
    Provider: SyncProvider & Sendable
> where Provider.ID: Sendable, Provider.Value: Sendable {
    let serializedProvider: Provider

    init(serializing provider: Provider) {
        self.serializedProvider = provider
    }

    fileprivate func serializedValue(for id: Provider.ID) throws(Provider.Failure) -> Provider.Value {
        try serializedProvider.value(for: id)
    }
}

extension SyncProviderSerializer: AsyncProvider {
    nonisolated
    func value(for id: Provider.ID) async throws(Provider.Failure) -> Provider.Value {
        try await serializedValue(for: id)
    }
}

public extension SyncProvider where Self: Sendable, ID: Sendable, Value: Sendable {
    /**
     Returns a wrapper for a ``SyncProvider`` `& Sendable` that guarantees serialization.

     If a ``SyncProvider`` needs to be used in an `async` context and it doesn't play well with reentrancy —usually
     because you want to avoid data races with its state management— you will want to use this operator to make an
     ``AsyncCache`` out of it.

     This is not particularly problematic for very fast providers i.e. generative ones that don't take long and require
     access to a common resource that would cause data races if done concurrently.
     - Note: Value must be `Sendable` because of Swift 6.0 weirdness. Likely to be relaxed in Swift 6.1
     - Returns: An ``AsyncProvider`` version of the calling ``SyncProvider`` that runs its calls serially.
     */
    func serialized() -> some AsyncProvider<ID, Value, Failure> {
        SyncProviderSerializer(serializing: self)
    }
}
