//
//  Serialized.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

private struct SendableWrapper<ID: Hashable & Sendable, Value: Sendable, Failure: Error>: @unchecked Sendable {
    var valueForID: (ID) throws(Failure) -> Value
}

private actor SyncProviderSerializer<ID: Hashable & Sendable, Value: Sendable, Failure: Error> {
    let serializedProvider: SendableWrapper<ID, Value, Failure>

    init(serializing provider: SendableWrapper<ID, Value, Failure>) {
        self.serializedProvider = provider
    }

    func valueFor(id: ID) throws(Failure) -> Value {
        try serializedProvider.valueForID(id)
    }
}

public extension SyncProvider where ID: Sendable, Value: Sendable {
    /**
     Returns a wrapper for a sync provider that guarantees serialization.

     If a sync provider needs to be used in an `async` context and it doesn't play well with concurrency —usually
     because you want to avoid data races with its state management— you will want to wrap it in one of these.

     - TODO: Talk about required sendability of ID & Value.
     - TODO: Talk about IKWID for making valueForID functionally `@Sendable`
     - Returns: An `async` provider version of the calling `SyncProvider` that runs its calls serially.
     */
    func serialized() -> AsyncProvider<ID, Value, Failure> {
        let serializedProvider = SyncProviderSerializer(serializing: .init(valueForID: self.valueForID))

        return AsyncProvider { id throws(Failure) in
            try await serializedProvider.valueFor(id: id)
        }
    }
}
