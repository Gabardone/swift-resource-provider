//
//  SideEffect.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

// MARK: - SyncProvider Side Effect

private struct SideEffectedNeverFailureSyncProvider<Effected: SyncProvider>: SyncProvider {
    typealias SideEffect = (Effected.Value, Effected.ID) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) throws(Effected.Failure) -> Effected.Value {
        let result = try sideEffected.value(for: id)
        sideEffect(result, id)
        return result
    }
}

public extension SyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect(
        _ sideEffect: @escaping (Value, ID) -> Void
    ) -> some SyncProvider<ID, Value, Failure> {
        SideEffectedNeverFailureSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct SideEffectedSameFailureSyncProvider<Effected: SyncProvider>: SyncProvider {
    typealias SideEffect = (Effected.Value, Effected.ID) throws(Effected.Failure) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) throws(Effected.Failure) -> Effected.Value {
        let result = try sideEffected.value(for: id)
        try sideEffect(result, id)
        return result
    }
}

public extension SyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping (Value, ID) throws(OtherFailure) -> Void
    ) -> some SyncProvider<ID, Value, Failure> where OtherFailure == Failure {
        SideEffectedSameFailureSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct SideEffectedAnyFailureSyncProvider<Effected: SyncProvider, SideEffectError: Error>: SyncProvider {
    typealias SideEffect = (Effected.Value, Effected.ID) throws(SideEffectError) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) throws -> Effected.Value {
        let result = try sideEffected.value(for: id)
        try sideEffect(result, id)
        return result
    }
}

public extension SyncProvider {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping (Value, ID) throws(OtherFailure) -> Void
    ) -> some SyncProvider<ID, Value, any Error> {
        SideEffectedAnyFailureSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct SideEffectedNewFailureSyncProvider<
    Effected: SyncProvider,
    SideEffectError: Error
>: SyncProvider where Effected.Failure == Never {
    typealias SideEffect = (Effected.Value, Effected.ID) throws(SideEffectError) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) throws(SideEffectError) -> Effected.Value {
        let result = sideEffected.value(for: id)
        try sideEffect(result, id)
        return result
    }
}

public extension SyncProvider where Failure == Never {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping (Value, ID) throws(OtherFailure) -> Void
    ) -> some SyncProvider<ID, Value, OtherFailure> {
        SideEffectedNewFailureSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

// MARK: - SyncProvider & Sendable Side Effect

private struct SideEffectedNeverFailureSendableSyncProvider<Effected: SyncProvider & Sendable>: SyncProvider & Sendable {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) throws(Effected.Failure) -> Effected.Value {
        let result = try sideEffected.value(for: id)
        sideEffect(result, id)
        return result
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect(
        _ sideEffect: @escaping @Sendable (Value, ID) -> Void
    ) -> some SendableSyncProvider<ID, Value, Failure> {
        SideEffectedNeverFailureSendableSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct SideEffectedSameFailureSendableSyncProvider<Effected: SyncProvider & Sendable>: SyncProvider & Sendable {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) throws(Effected.Failure) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) throws(Effected.Failure) -> Effected.Value {
        let result = try sideEffected.value(for: id)
        try sideEffect(result, id)
        return result
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) throws(OtherFailure) -> Void
    ) -> some SendableSyncProvider<ID, Value, Failure> where OtherFailure == Failure {
        SideEffectedSameFailureSendableSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct SideEffectedAnyFailureSendableSyncProvider<
    Effected: SyncProvider & Sendable,
    SideEffectError: Error
>: SyncProvider & Sendable {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) throws(SideEffectError) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) throws -> Effected.Value {
        let result = try sideEffected.value(for: id)
        try sideEffect(result, id)
        return result
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) throws(OtherFailure) -> Void
    ) -> some SendableSyncProvider<ID, Value, any Error> {
        SideEffectedAnyFailureSendableSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct SideEffectedNewFailureSendableSyncProvider<
    Effected: SyncProvider & Sendable,
    SideEffectError: Error
>: SyncProvider, Sendable where Effected.Failure == Never {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) throws(SideEffectError) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) throws(SideEffectError) -> Effected.Value {
        let result = sideEffected.value(for: id)
        try sideEffect(result, id)
        return result
    }
}

public extension SyncProvider where Self: Sendable, Failure == Never {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) throws(OtherFailure) -> Void
    ) -> some SendableSyncProvider<ID, Value, OtherFailure> {
        SideEffectedNewFailureSendableSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

// MARK: - AsyncProvider Sync Side Effect

private struct SyncSideEffectedNeverFailureAsyncProvider<Effected: AsyncProvider>: AsyncProvider {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) async throws(Effected.Failure) -> Effected.Value {
        let result = try await sideEffected.value(for: id)
        sideEffect(result, id)
        return result
    }
}

public extension AsyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect(
        _ sideEffect: @escaping @Sendable (Value, ID) -> Void
    ) -> some AsyncProvider<ID, Value, Failure> {
        SyncSideEffectedNeverFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct SyncSideEffectedSameFailureAsyncProvider<Effected: AsyncProvider>: AsyncProvider {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) throws(Effected.Failure) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) async throws(Effected.Failure) -> Effected.Value {
        let result = try await sideEffected.value(for: id)
        try sideEffect(result, id)
        return result
    }
}

public extension AsyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) throws(OtherFailure) -> Void
    ) -> some AsyncProvider<ID, Value, Failure> where OtherFailure == Failure {
        SyncSideEffectedSameFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct SyncSideEffectedAnyFailureAsyncProvider<Effected: AsyncProvider, SideEffectError: Error>: AsyncProvider {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) throws(SideEffectError) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) async throws -> Effected.Value {
        let result = try await sideEffected.value(for: id)
        try sideEffect(result, id)
        return result
    }
}

public extension AsyncProvider {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) throws(OtherFailure) -> Void
    ) -> some AsyncProvider<ID, Value, any Error> {
        SyncSideEffectedAnyFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct SyncSideEffectedNewFailureAsyncProvider<
    Effected: AsyncProvider,
    SideEffectError: Error
>: AsyncProvider where Effected.Failure == Never {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) throws(SideEffectError) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) async throws(SideEffectError) -> Effected.Value {
        let result = await sideEffected.value(for: id)
        try sideEffect(result, id)
        return result
    }
}

public extension AsyncProvider where Failure == Never {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) throws(OtherFailure) -> Void
    ) -> some AsyncProvider<ID, Value, OtherFailure> {
        SyncSideEffectedNewFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

// MARK: - AsyncProvider Async Side Effect

private struct AsyncSideEffectedNeverFailureAsyncProvider<Effected: AsyncProvider>: AsyncProvider {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) async -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) async throws(Effected.Failure) -> Effected.Value {
        let result = try await sideEffected.value(for: id)
        await sideEffect(result, id)
        return result
    }
}

public extension AsyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect(
        _ sideEffect: @escaping @Sendable (Value, ID) async -> Void
    ) -> some AsyncProvider<ID, Value, Failure> {
        AsyncSideEffectedNeverFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct AsyncSideEffectedSameFailureAsyncProvider<Effected: AsyncProvider>: AsyncProvider {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) async throws(Effected.Failure) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) async throws(Effected.Failure) -> Effected.Value {
        let result = try await sideEffected.value(for: id)
        try await sideEffect(result, id)
        return result
    }
}

public extension AsyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) async throws(OtherFailure) -> Void
    ) -> some AsyncProvider<ID, Value, Failure> where OtherFailure == Failure {
        AsyncSideEffectedSameFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct AsyncSideEffectedAnyFailureAsyncProvider<Effected: AsyncProvider, SideEffectError: Error>: AsyncProvider {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) async throws(SideEffectError) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) async throws -> Effected.Value {
        let result = try await sideEffected.value(for: id)
        try await sideEffect(result, id)
        return result
    }
}

public extension AsyncProvider {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) async throws(OtherFailure) -> Void
    ) -> some AsyncProvider<ID, Value, any Error> {
        AsyncSideEffectedAnyFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct AsyncSideEffectedNewFailureAsyncProvider<
    Effected: AsyncProvider,
    SideEffectError: Error
>: AsyncProvider where Effected.Failure == Never {
    typealias SideEffect = @Sendable (Effected.Value, Effected.ID) async throws(SideEffectError) -> Void

    var sideEffected: Effected

    var sideEffect: SideEffect

    func value(for id: Effected.ID) async throws(SideEffectError) -> Effected.Value {
        let result = await sideEffected.value(for: id)
        try await sideEffect(result, id)
        return result
    }
}

public extension AsyncProvider where Failure == Never {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) async throws(OtherFailure) -> Void
    ) -> some AsyncProvider<ID, Value, OtherFailure> {
        AsyncSideEffectedNewFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}
