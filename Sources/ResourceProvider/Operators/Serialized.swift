//
//  Serialized.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

private actor SyncProviderSerializer<ID: Hashable, Value> {
    let serializedProvider: (ID) -> Value

    init(serializing provider: @escaping (ID) -> Value) {
        self.serializedProvider = provider
    }

    func valueFor(id: ID) -> Value {
        serializedProvider(id)
    }
}

public extension SyncProvider where ID: Sendable, Value: Sendable {
    /**
     Returns a wrapper for a sync provider that guarantees serialization.

     If a sync provider needs to be used in an `async` context and it doesn't play well with concurrency —usually
     because you want to avoid data races with its state management— you will want to wrap it in one of these.
     - Returns: An `async` provider version of the calling `SyncProvider` that runs its calls serially.
     */
    func serialized() -> AsyncProvider<ID, Value> {
        let serializedProvider = SyncProviderSerializer(serializing: valueForID)

        return AsyncProvider { id in
            await serializedProvider.valueFor(id: id)
        }
    }
}

private actor ThrowingSyncProviderSerializer<ID: Hashable, Value> {
    typealias Serialized = ThrowingSyncProvider<ID, Value>

    let serialized: Serialized

    init(serializing provider: Serialized) {
        self.serialized = provider
    }

    func valueFor(id: ID) throws -> Value {
        try serialized.valueForID(id)
    }
}

public extension ThrowingSyncProvider where ID: Sendable, Value: Sendable {
    /**
     Returns a wrapper for a throwing sync provider that guarantees serialization.

     If a throwing sync provider needs to be used in an `async` context and it doesn't play well with concurrency
     —usually because you want to avoid data races with its state management— you will want to wrap it in one of these.
     - Returns: A throwing `async` provider version of the calling `ThrowingSyncProvider` that runs its calls serially.
     */
    func serialized() -> ThrowingAsyncProvider<ID, Value> {
        let serializedProvider = ThrowingSyncProviderSerializer(serializing: self)

        return ThrowingAsyncProvider { id in
            try await serializedProvider.valueFor(id: id)
        }
    }
}
