//
//  Interject+AsyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

// swiftlint:disable type_name

// MARK: - AsyncProvider Sync Interjection

private struct SyncInterjectingNeverFailureAsyncProvider<Interjected: AsyncProvider>: AsyncProvider {
    typealias Interjector = @Sendable (Interjected.ID) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) async throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = interjector(id) {
            interjection
        } else {
            try await interjected.value(for: id)
        }
    }
}

public extension AsyncProvider {
    func interject(_ interject: @escaping @Sendable (ID) -> Value?) -> some AsyncProvider<ID, Value, Failure> {
        SyncInterjectingNeverFailureAsyncProvider(interjected: self, interjector: interject)
    }
}

private struct SyncInterjectingSameFailureAsyncProvider<Interjected: AsyncProvider>: AsyncProvider {
    typealias Interjector = @Sendable (Interjected.ID) throws(Interjected.Failure) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) async throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try await interjected.value(for: id)
        }
    }
}

public extension AsyncProvider {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) throws(OtherFailure) -> Value?
    ) -> some AsyncProvider<ID, Value, Failure> where OtherFailure == Failure {
        SyncInterjectingSameFailureAsyncProvider(interjected: self, interjector: interject)
    }
}

private struct SyncInterjectingAnyFailureAsyncProvider<
    Interjected: AsyncProvider,
    InterjectionError: Error
>: AsyncProvider {
    typealias Interjector = @Sendable (Interjected.ID) throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) async throws -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try await interjected.value(for: id)
        }
    }
}

public extension AsyncProvider {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) throws(OtherFailure) -> Value?
    ) -> some AsyncProvider<ID, Value, any Error> {
        SyncInterjectingAnyFailureAsyncProvider(interjected: self, interjector: interject)
    }
}

private struct SyncInterjectingNewFailureAsyncProvider<
    Interjected: AsyncProvider,
    InterjectionError: Error
>: AsyncProvider where Interjected.Failure == Never {
    typealias Interjector = @Sendable (Interjected.ID) throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) async throws(InterjectionError) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            await interjected.value(for: id)
        }
    }
}

extension AsyncProvider where Failure == Never {
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) throws(OtherFailure) -> Value?
    ) -> some AsyncProvider<ID, Value, OtherFailure> {
        SyncInterjectingNewFailureAsyncProvider(interjected: self, interjector: interject)
    }
}

// MARK: - AsyncProvider Async Interjection

private struct AsyncInterjectingNeverFailureAsyncProvider<Interjected: AsyncProvider>: AsyncProvider {
    typealias Interjector = @Sendable (Interjected.ID) async -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) async throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = await interjector(id) {
            interjection
        } else {
            try await interjected.value(for: id)
        }
    }
}

public extension AsyncProvider {
    func interject(_ interject: @escaping @Sendable (ID) async -> Value?) -> some AsyncProvider<ID, Value, Failure> {
        AsyncInterjectingNeverFailureAsyncProvider(interjected: self, interjector: interject)
    }
}

private struct AsyncInterjectingSameFailureAsyncProvider<Interjected: AsyncProvider>: AsyncProvider {
    typealias Interjector = @Sendable (Interjected.ID) async throws(Interjected.Failure) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) async throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = try await interjector(id) {
            interjection
        } else {
            try await interjected.value(for: id)
        }
    }
}

public extension AsyncProvider {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) async throws(OtherFailure) -> Value?
    ) -> some AsyncProvider<ID, Value, Failure> where OtherFailure == Failure {
        AsyncInterjectingSameFailureAsyncProvider(interjected: self, interjector: interject)
    }
}

private struct AsyncInterjectingAnyFailureAsyncProvider<
    Interjected: AsyncProvider,
    InterjectionError: Error
>: AsyncProvider {
    typealias Interjector = @Sendable (Interjected.ID) async throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) async throws -> Interjected.Value {
        if let interjection = try await interjector(id) {
            interjection
        } else {
            try await interjected.value(for: id)
        }
    }
}

public extension AsyncProvider {
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) async throws(OtherFailure) -> Value?
    ) -> some AsyncProvider<ID, Value, any Error> {
        AsyncInterjectingAnyFailureAsyncProvider(interjected: self, interjector: interject)
    }
}

private struct AsyncInterjectingNewFailureAsyncProvider<
    Interjected: AsyncProvider,
    InterjectionError: Error
>: AsyncProvider where Interjected.Failure == Never {
    typealias Interjector = @Sendable (Interjected.ID) async throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) async throws(InterjectionError) -> Interjected.Value {
        if let interjection = try await interjector(id) {
            interjection
        } else {
            await interjected.value(for: id)
        }
    }
}

extension AsyncProvider where Failure == Never {
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) async throws(OtherFailure) -> Value?
    ) -> some AsyncProvider<ID, Value, OtherFailure> {
        AsyncInterjectingNewFailureAsyncProvider(interjected: self, interjector: interject)
    }
}

// swiftlint:enable type_name
