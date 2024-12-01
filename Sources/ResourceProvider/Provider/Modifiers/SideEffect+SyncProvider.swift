//
//  SideEffect+SyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

// swiftlint:disable type_name

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
     Runs a side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect doesn't `throw`.
     - Parameter sideEffect: A block that takes both the requested `id` and the value returned for it and can do
     whatever it wants on the side.
     - Returns: A ``SyncProvider`` that has the given side effect when returning a value.
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
     Runs a side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors of the same type as the modified
     ``SyncProvider``.
     - Parameter sideEffect: A block that takes both the requested `id` and the value returned for it and can do
     whatever it wants on the side, including throwing an error of type `Failure`.
     - Returns: A ``SyncProvider`` that has the given side effect when returning a value.
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
     Runs a side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors of a different type than those thrown by the
     modified ``SyncProvider``.
     - Parameter sideEffect: A block that takes both the requested `id` and the value returned for it and can do
     whatever it wants on the side, including throwing an error of type `OtherFailure`.
     - Returns: A ``SyncProvider`` that has the given side effect when returning a value and may `throw` an error.
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
     Runs a side effect informed by the returned value and requested id.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors and is modifying a ``SyncProvider`` that
     does not throw any.
     - Parameter sideEffect: A block that takes both the requested `id` and the value returned for it and can do
     whatever it wants on the side, including throwing an error of type `OtherFailure`.
     - Returns: A ``SyncProvider`` that has the given side effect when returning a value and may `throw` an error
     of type `OtherFailure`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping (Value, ID) throws(OtherFailure) -> Void
    ) -> some SyncProvider<ID, Value, OtherFailure> {
        SideEffectedNewFailureSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

// MARK: - SyncProvider & Sendable Side Effect

private struct SideEffectedNeverFailureSendableSyncProvider<
    Effected: SyncProvider & Sendable
>: SyncProvider & Sendable {
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
     Runs a side effect informed by the returned value and requested id, maintaining sendability.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect doesn't `throw`.
     - Parameter sideEffect: A `@Sendable` block that takes both the requested `id` and the value returned for it and
     can do whatever it wants on the side.
     - Returns: A ``SyncProvider`` `& Sendable` that has the given side effect when returning a value.
     */
    func sideEffect(
        _ sideEffect: @escaping @Sendable (Value, ID) -> Void
    ) -> some SyncProvider<ID, Value, Failure> & Sendable {
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
     Runs a side effect informed by the returned value and requested id, maintaining sendability.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors of the same type as the modified
     ``SyncProvider``.
     - Parameter sideEffect: A `@Sendable` block that takes both the requested `id` and the value returned for it and
     can do whatever it wants on the side, including throwing an error of type `Failure`.
     - Returns: A ``SyncProvider`` `& Sendable` that has the given side effect when returning a value.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) throws(OtherFailure) -> Void
    ) -> some SyncProvider<ID, Value, Failure> & Sendable where OtherFailure == Failure {
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
     Runs a side effect informed by the returned value and requested id, maintaining sendability.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors of a different type than those thrown by the
     modified ``SyncProvider``.
     - Parameter sideEffect: A `@Sendable` block that takes both the requested `id` and the value returned for it and
     can do whatever it wants on the side, including throwing an error of type `OtherFailure`.
     - Returns: A ``SyncProvider`` `& Sendable` that has the given side effect when returning a value and may `throw` an
     error.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) throws(OtherFailure) -> Void
    ) -> some SyncProvider<ID, Value, any Error> & Sendable {
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
     Runs a side effect informed by the returned value and requested id, maintaining sendability.

     If you need a side effect when the provider returns a value and have no need to alter it, use this modifier instead
     of `mapValue`. Examples would be logging, testing validation, or storing returned values into a cache.

     This modifier is not called if the modified provider throws an error. If you want to deal with those, use `catch`.

     The compiler picks this overload when the side effect throws errors and is modifying a ``SyncProvider`` that
     does not throw any.
     - Parameter sideEffect: A `@Sendable` block that takes both the requested `id` and the value returned for it and
     can do whatever it wants on the side, including throwing an error of type `OtherFailure`.
     - Returns: A ``SyncProvider`` `& Sendable` that has the given side effect when returning a value and may `throw` an
     error of type `OtherFailure`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping @Sendable (Value, ID) throws(OtherFailure) -> Void
    ) -> some SyncProvider<ID, Value, OtherFailure> & Sendable {
        SideEffectedNewFailureSendableSyncProvider(sideEffected: self, sideEffect: sideEffect)
    }
}

// swiftlint:enable type_name
