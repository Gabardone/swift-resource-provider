//
//  Interject.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

// MARK: - SyncProvider Interjection

private struct InterjectingSameFailureSyncProvider<Interjected: SyncProvider>: SyncProvider {
    typealias Interjector = (Interjected.ID) throws(Interjected.Failure) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func valueFor(id: Interjected.ID) throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try interjected.valueFor(id: id)
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
    func interject(_ interject: @escaping (ID) throws(Failure) -> Value?) -> some SyncProvider<ID, Value, Failure> {
        InterjectingSameFailureSyncProvider(interjected: self, interjector: interject)
    }
}

private struct InterjectingAnyFailureSyncProvider<Interjected: SyncProvider, InterjectionError: Error>: SyncProvider {
    typealias Interjector = (Interjected.ID) throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func valueFor(id: Interjected.ID) throws(any Error) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try interjected.valueFor(id: id)
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

    func valueFor(id: Interjected.ID) throws(InterjectionError) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            interjected.valueFor(id: id)
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

// MARK: - Sendable SyncProvider Interjection

private struct InterjectingSameFailureSendableSyncProvider<
    Interjected: SyncProvider & Sendable
>: SyncProvider, Sendable {
    typealias Interjector = @Sendable (Interjected.ID) throws(Interjected.Failure) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func valueFor(id: Interjected.ID) throws(Interjected.Failure) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try interjected.valueFor(id: id)
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
        _ interject: @escaping @Sendable (ID) throws(Failure) -> Value?
    ) -> some SyncProvider<ID, Value, Failure> & Sendable {
        InterjectingSameFailureSendableSyncProvider(interjected: self, interjector: interject)
    }
}

private struct InterjectingAnyFailureSendableSyncProvider<
    Interjected: SyncProvider & Sendable,
    InterjectionError: Error
>: SyncProvider, Sendable {
    typealias Interjector = @Sendable (Interjected.ID) throws(InterjectionError) -> Interjected.Value?

    var interjected: Interjected

    var interjector: Interjector

    func valueFor(id: Interjected.ID) throws(any Error) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            try interjected.valueFor(id: id)
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
    ) -> some SyncProvider<ID, Value, any Error> & Sendable {
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

    func valueFor(id: Interjected.ID) throws(InterjectionError) -> Interjected.Value {
        if let interjection = try interjector(id) {
            interjection
        } else {
            interjected.valueFor(id: id)
        }
    }
}

extension SyncProvider where Failure == Never, Self: Sendable {
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
    ) -> some SyncProvider<ID, Value, OtherFailure> & Sendable {
        InterjectingNewFailureSendableSyncProvider(interjected: self, interjector: interject)
    }
}

// MARK: - AsyncProvider Interjection

public extension AsyncProvider {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @Sendable @escaping (ID) throws(Failure) -> Value?) -> Self {
        .init { id throws(Failure) in
            if let result = try interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @Sendable @escaping (ID) throws(OtherFailure) -> Value?
    ) -> AsyncProvider<ID, Value, any Error> {
        .init { id in
            if let result = try interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @Sendable @escaping (ID) async throws(Failure) -> Value?) -> AsyncProvider {
        .init { id throws(Failure) in
            if let result = try await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @Sendable @escaping (ID) async throws(OtherFailure) -> Value?
    ) -> AsyncProvider<ID, Value, any Error> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }
}

public extension AsyncProvider where Failure == Never {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @Sendable @escaping (ID) throws(OtherFailure) -> Value?
    ) -> AsyncProvider<ID, Value, OtherFailure> {
        .init { id throws(OtherFailure) in
            if let interjected = try interject(id) {
                interjected
            } else {
                await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @Sendable @escaping (ID) async throws(OtherFailure) -> Value?
    ) -> AsyncProvider<ID, Value, OtherFailure> {
        .init { id throws(OtherFailure) in
            if let interjected = try await interject(id) {
                interjected
            } else {
                await valueForID(id)
            }
        }
    }
}
