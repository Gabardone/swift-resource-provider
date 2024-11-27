//
//  Interject+SyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

// swiftlint:disable type_name

// MARK: - SyncProvider Interjection

private struct InterjectingNeverFailureSyncProvider<Interjected: SyncProvider>: SyncProvider {
    typealias Interjector = (Interjected.ID) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = interjector(id) {
            interjection
        } else {
            try interjected.value(for: id)
        }
    }
}

public extension SyncProvider {
    /**
     Intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.
     - Parameter interject: A block that takes an `id` and either returns a value, returns `nil`.
     - Returns: A ``SyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id`.
     */
    func interject(_ interject: @escaping (ID) -> Value?) -> some SyncProvider<ID, Value, Failure> {
        InterjectingNeverFailureSyncProvider(interjected: self, interjector: interject)
    }
}

private struct InterjectingSameFailureSyncProvider<Interjected: SyncProvider>: SyncProvider {
    typealias Interjector = (Interjected.ID) throws(Interjected.Failure) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try interjected.value(for: id)
        }
    }
}

public extension SyncProvider {
    /**
     Intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.

     This override also applies when both the interjection logic and modified provider have a failure type of `Never`,
     in which case no one will be throwing anything.
     - Parameter interject: A block that takes an `id` and either returns a value, returns `nil` or (if
     `OtherFailure != Never`) throws an error.
     - Returns: A ``SyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping (ID) throws(OtherFailure) -> Value?
    ) -> some SyncProvider<ID, Value, Failure> where OtherFailure == Failure {
        InterjectingSameFailureSyncProvider(interjected: self, interjector: interject)
    }
}

private struct InterjectingAnyFailureSyncProvider<Interjected: SyncProvider, InterjectionError: Error>: SyncProvider {
    typealias Interjector = (Interjected.ID) throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) throws -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try interjected.value(for: id)
        }
    }
}

public extension SyncProvider {
    /**
     Intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.

     This is the most disfavored overload.  If the errors thrown by the modified provider and the interjection block
     are of different types the resulting provider will throw `any Error`.
     - Parameter interject: A synchronous block that takes an `id` and either returns a value, returns `nil` or throws
     an error.
     - Returns: A ``SyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping (ID) throws(OtherFailure) -> Value?
    ) -> some SyncProvider<ID, Value, any Error> {
        InterjectingAnyFailureSyncProvider(interjected: self, interjector: interject)
    }
}

private struct InterjectingNewFailureSyncProvider<
    Interjected: SyncProvider,
    InterjectionError: Error
>: SyncProvider where Interjected.Failure == Never {
    typealias Interjector = (Interjected.ID) throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) throws(InterjectionError) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            interjected.value(for: id)
        }
    }
}

extension SyncProvider where Failure == Never {
    /**
     Intercepts a provider's value request and may optionally decide to return a different one instead.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally.
     - Parameter interject: A synchronous block that takes an `id` and either returns a value, returns `nil` or throws
     an error.
     - Returns: A ``SyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping (ID) throws(OtherFailure) -> Value?
    ) -> some SyncProvider<ID, Value, OtherFailure> {
        InterjectingNewFailureSyncProvider(interjected: self, interjector: interject)
    }
}

// MARK: - SyncProvider & Sendable Interjection

private struct InterjectingNoFailureSendableSyncProvider<
    Interjected: SyncProvider & Sendable
>: SyncProvider, Sendable {
    typealias Interjector = @Sendable (Interjected.ID) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = interjector(id) {
            interjection
        } else {
            try interjected.value(for: id)
        }
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Intercepts a provider's value request and may optionally decide to return a different one instead, maintaining
     sendability.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.
     - Parameter interject: A block that takes an `id` and either returns a value, returns `nil`.
     - Returns: A ``SyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id`.
     */
    func interject(
        _ interject: @escaping @Sendable (ID) -> Value?
    ) -> some SendableSyncProvider<ID, Value, Failure> {
        InterjectingNoFailureSendableSyncProvider(interjected: self, interjector: interject)
    }
}

private struct InterjectingSameFailureSendableSyncProvider<
    Interjected: SyncProvider & Sendable
>: SyncProvider & Sendable {
    typealias Interjector = @Sendable (Interjected.ID) throws(Interjected.Failure) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try interjected.value(for: id)
        }
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Intercepts a provider's value request and may optionally decide to return a different one instead, maintaining
     sendability.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.

     This override also applies when both the interjection logic and modified provider have a failure type of `Never`,
     in which case no one will be throwing anything.
     - Parameter interject: A block that takes an `id` and either returns a value, returns `nil` or (if
     `OtherFailure != Never`) throws an error.
     - Returns: A ``SyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) throws(OtherFailure) -> Value?
    ) -> some SendableSyncProvider<ID, Value, Failure> where OtherFailure == Failure {
        InterjectingSameFailureSendableSyncProvider(interjected: self, interjector: interject)
    }
}

private struct InterjectingAnyFailureSendableSyncProvider<
    Interjected: SyncProvider & Sendable,
    InterjectionError: Error
>: SyncProvider & Sendable {
    typealias Interjector = @Sendable (Interjected.ID) throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) throws -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try interjected.value(for: id)
        }
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Intercepts a provider's value request and may optionally decide to return a different one instead, maintaining
     sendability.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally, either returning a value or throwing
     an error.

     This is the most disfavored overload.  If the errors thrown by the modified provider and the interjection block
     are of different types the resulting provider will throw `any Error`.
     - Parameter interject: A synchronous block that takes an `id` and either returns a value, returns `nil` or throws
     an error.
     - Returns: An ``SyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) throws(OtherFailure) -> Value?
    ) -> some SendableSyncProvider<ID, Value, any Error> {
        InterjectingAnyFailureSendableSyncProvider(interjected: self, interjector: interject)
    }
}

private struct InterjectingNewFailureSendableSyncProvider<
    Interjected: SyncProvider & Sendable,
    InterjectionError: Error
>: SyncProvider, Sendable where Interjected.Failure == Never {
    typealias Interjector = @Sendable (Interjected.ID) throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func value(for id: Interjected.ID) throws(InterjectionError) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            interjected.value(for: id)
        }
    }
}

public extension SyncProvider where Self: Sendable, Failure == Never {
    /**
     Intercepts a provider's value request and may optionally decide to return a different one instead, maintaining
     sendability.

     The given logic will be called **before** requesting the value from the modified provider. If the interjection
     logic returns a value it will be returned by the provider and the modified provider **will not** be called. If it
     throws an error it will be rethrown by the provider to the caller.

     If the block returns `nil` the modified provider will be called normally.
     - Parameter interject: A synchronous block that takes an `id` and either returns a value, returns `nil` or throws
     an error.
     - Returns: A ``SyncProvider`` that allows the given block to take first dibs at returning a value for any given
     `id` or throwing an error.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) throws(OtherFailure) -> Value?
    ) -> some SendableSyncProvider<ID, Value, OtherFailure> {
        InterjectingNewFailureSendableSyncProvider(interjected: self, interjector: interject)
    }
}

// swiftlint:enable type_name
