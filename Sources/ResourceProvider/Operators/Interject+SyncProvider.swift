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
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
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
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
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
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
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
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
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
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
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
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
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
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
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
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping @Sendable (ID) throws(OtherFailure) -> Value?
    ) -> some SendableSyncProvider<ID, Value, OtherFailure> {
        InterjectingNewFailureSendableSyncProvider(interjected: self, interjector: interject)
    }
}

// swiftlint:enable type_name
