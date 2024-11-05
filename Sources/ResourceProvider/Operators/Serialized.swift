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
     Returns a wrapper for a sync provider that guarantees serialization.

     If a sync provider needs to be used in an `async` context and it doesn't play well with concurrency —usually
     because you want to avoid data races with its state management— you will want to wrap it in one of these.

     - Todo: Talk about required sendability of ID & Value.
     - Todo: Talk about IKWID for making valueForID functionally `@Sendable`
     - Returns: An `async` provider version of the calling `SyncProvider` that runs its calls serially.
     */
    func serialized() -> some AsyncProvider<ID, Value, Failure> {
        SyncProviderSerializer(serializing: self)
    }
}
