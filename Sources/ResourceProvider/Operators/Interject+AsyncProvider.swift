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
    /**
     Synchronously intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.
     - Parameter interject: A synchronous block that takes an `id` and either returns a value, returns `nil`.
     - Returns: An ``AsyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id`.
     */
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
     Synchronously intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.

     This override also applies when both the interjection logic and modified provider have a failure type of `Never`,
     in which case no one will be throwing anything.
     - Parameter interject: A synchronous block that takes an `id` and either returns a value, returns `nil` or (if
     `OtherFailure != Never`) throws an error.
     - Returns: An ``AsyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
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
     Synchronously intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.

     This is the most disfavored overload.  If the errors thrown by the modified provider and the interjection block
     are of different types the resulting provider will throw `any Error`.
     - Parameter interject: A synchronous block that takes an `id` and either returns a value, returns `nil` or throws
     an error.
     - Returns: An ``AsyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
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
    /**
     Synchronously intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally.
     - Parameter interject: A synchronous block that takes an `id` and either returns a value, returns `nil` or throws
     an error.
     - Returns: An ``AsyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
     */
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
    /**
     Asynchronously intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.
     - Parameter interject: An `async` block that takes an `id` and either returns a value, returns `nil`.
     - Returns: An ``AsyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id`.
     */
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
     Asynchronously intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.

     This override also applies when both the interjection logic and modified provider have a failure type of `Never`,
     in which case no one will be throwing anything.
     - Parameter interject: An `async` block that takes an `id` and either returns a value, returns `nil` or (if
     `OtherFailure != Never`) throws an error.
     - Returns: An ``AsyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
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
    /**
     Asynchronously intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.

     This is the most disfavored overload.  If the errors thrown by the modified provider and the interjection block
     are of different types the resulting provider will throw `any Error`.
     - Parameter interject: An `async` block that takes an `id` and either returns a value, returns `nil` or throws
     an error.
     - Returns: An ``AsyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
     */
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
    /**
     Asynchronously intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally.
     - Parameter interject: An `async` block that takes an `id` and either returns a value, returns `nil` or throws
     an error.
     - Returns: An ``AsyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) async throws(OtherFailure) -> Value?
    ) -> some AsyncProvider<ID, Value, OtherFailure> {
        AsyncInterjectingNewFailureAsyncProvider(interjected: self, interjector: interject)
    }
}

// swiftlint:enable type_name
