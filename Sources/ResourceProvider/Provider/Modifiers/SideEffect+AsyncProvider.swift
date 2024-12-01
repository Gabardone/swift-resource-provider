//
//  SideEffect+AsyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

// swiftlint:disable type_name

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
     Runs a synchronous side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect doesn't `throw`.
     - Parameter sideEffect: A synchronous block that takes both the requested `id` and the value returned for it and
     can do whatever it wants on the side.
     - Returns: An ``AsyncProvider`` that has the given side effect when returning a value.
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
     Runs a synchronous side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors of the same type as the modified
     ``AsyncProvider``.
     - Parameter sideEffect: A synchronous block that takes both the requested `id` and the value returned for it and
     can do whatever it wants on the side, including throwing an error of type `Failure`.
     - Returns: An ``AsyncProvider`` that has the given side effect when returning a value.
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
     Runs a synchronous side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors of a different type than those thrown by the
     modified ``AsyncProvider``.
     - Parameter sideEffect: A synchronous block that takes both the requested `id` and the value returned for it and
     can do whatever it wants on the side, including throwing an error of type `OtherFailure`.
     - Returns: An ``AsyncProvider`` that has the given side effect when returning a value and may `throw` an error.
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
     Runs a synchronous side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors and is modifying an ``AsyncProvider`` that
     does not throw any.
     - Parameter sideEffect: A synchronous block that takes both the requested `id` and the value returned for it and
     can do whatever it wants on the side, including throwing an error of type `OtherFailure`.
     - Returns: An ``AsyncProvider`` that has the given side effect when returning a value and may `throw` an error
     of type `OtherFailure`.
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
     Runs an `async` side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect doesn't `throw`.
     - Parameter sideEffect: An `async` block that takes both the requested `id` and the value returned for it and can
     do whatever it wants on the side.
     - Returns: An ``AsyncProvider`` that has the given side effect when returning a value.
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
     Runs an `async` side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors of the same type as the modified
     ``AyncProvider``.
     - Parameter sideEffect: An `async` block that takes both the requested `id` and the value returned for it and can
     do whatever it wants on the side, including throwing an error of type `Failure`.
     - Returns: An ``AsyncProvider`` that has the given side effect when returning a value.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) async throws(OtherFailure) -> Void
    ) -> some AsyncProvider<ID, Value, Failure> where OtherFailure == Failure {
        AsyncSideEffectedSameFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

private struct AsyncSideEffectedAnyFailureAsyncProvider<
    Effected: AsyncProvider, SideEffectError: Error
>: AsyncProvider {
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
     Runs an `async` side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors of a different type than those thrown by the
     modified ``AyncProvider``.
     - Parameter sideEffect: An `async` block that takes both the requested `id` and the value returned for it and can
     do whatever it wants on the side, including throwing an error of type `OtherFailure`.
     - Returns: An ``AsyncProvider`` that has the given side effect when returning a value and may `throw` an error.
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
     Runs an `async` side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors and is modifying an ``AsyncProvider`` that
     does not throw any.
     - Parameter sideEffect: An `async` block that takes both the requested `id` and the value returned for it and can
     do whatever it wants on the side, including throwing an error of type `OtherFailure`.
     - Returns: An ``AsyncProvider`` that has the given side effect when returning a value and may `throw` an error
     of type `OtherFailure`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) async throws(OtherFailure) -> Void
    ) -> some AsyncProvider<ID, Value, OtherFailure> {
        AsyncSideEffectedNewFailureAsyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

// swiftlint:enable type_name
