//
//  MapValue+AsyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

// swiftlint:disable type_name

// MARK: - AsyncProvider Sync Map Value

private struct SyncValueMappingNeverFailureAsyncProvider<Mapped: AsyncProvider, Value>: AsyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws(Mapped.Failure) -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider {
    /**
     Synchronously maps an ``AsyncProvider`` returned values to different ones.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A synchronous block that translates a returning value to another value of type `OtherValue`.
     It gets both the value and the id that was requested to return it.
     - Returns: An ``AsyncProvider`` that returns values of type `OtherValue`.
     */
    func mapValue<OtherValue>(
        _ transform: @escaping @Sendable (Value, ID) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, Failure> {
        SyncValueMappingNeverFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct SyncValueMappingSameFailureAsyncProvider<Mapped: AsyncProvider, Value>: AsyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(Mapped.Failure) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws(Mapped.Failure) -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider {
    /**
     Synchronously maps an ``AsyncProvider`` returned values to different ones, possibly throwing an error instead.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A synchronous block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: An ``AsyncProvider`` that returns values of type `OtherValue` or throws.
     */
    @_disfavoredOverload
    func mapValue<OtherValue>(
        _ transform: @escaping @Sendable (Value, ID) throws(Failure) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, Failure> {
        SyncValueMappingSameFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct SyncValueMappingAnyFailureAsyncProvider<
    Mapped: AsyncProvider,
    Value,
    ValueMappingError: Error
>: AsyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider {
    /**
     Synchronously maps an ``AsyncProvider`` returned values to different ones, possibly throwing an error instead.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.

     This is the most disfavored overload.  If the errors thrown by the modified provider and the transform block
     are of different types the resulting provider will throw `any Error`.
     - Parameter transform: A synchronous block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: An ``AsyncProvider`` that returns values of type `OtherValue` or throws.
     */
    @_disfavoredOverload
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, any Error> {
        SyncValueMappingAnyFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct SyncValueMappingNewFailureAsyncProvider<
    Mapped: AsyncProvider,
    Value,
    ValueMappingError: Error
>: AsyncProvider where Mapped.Failure == Never {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws(ValueMappingError) -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider where Failure == Never {
    /**
     Synchronously maps an ``AsyncProvider`` returned values to different ones, possibly throwing an error instead.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A synchronous block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: An ``AsyncProvider`` that returns values of type `OtherValue`.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, OtherFailure> {
        SyncValueMappingNewFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

// MARK: - AsyncProvider Async Map Value

private struct AsyncValueMappingNeverFailureAsyncProvider<Mapped: AsyncProvider, Value>: AsyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) async -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws(Mapped.Failure) -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider {
    /**
     Asynchronously maps an ``AsyncProvider`` returned values to different ones.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: An `async` block that translates a returning value to another value of type `OtherValue`. It
     gets both the value and the id that was requested to return it.
     - Returns: An ``AsyncProvider`` that returns values of type `OtherValue`.
     */
    func mapValue<OtherValue>(
        _ transform: @escaping @Sendable (Value, ID) async -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, Failure> {
        AsyncValueMappingNeverFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct AsyncValueMappingSameFailureAsyncProvider<Mapped: AsyncProvider, Value>: AsyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) async throws(Mapped.Failure) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws(Mapped.Failure) -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider {
    /**
     Asynchronously maps an ``AsyncProvider`` returned values to different ones, possibly throwing an error instead.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: An `async` block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: An ``AsyncProvider`` that returns values of type `OtherValue` or throws.
     */
    @_disfavoredOverload
    func mapValue<OtherValue>(
        _ transform: @escaping @Sendable (Value, ID) async throws(Failure) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, Failure> {
        AsyncValueMappingSameFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct AsyncValueMappingAnyFailureAsyncProvider<
    Mapped: AsyncProvider,
    Value,
    ValueMappingError: Error
>: AsyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) async throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider {
    /**
     Asynchronously maps an ``AsyncProvider`` returned values to different ones, possibly throwing an error instead.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.

     This is the most disfavored overload.  If the errors thrown by the modified provider and the transform block
     are of different types the resulting provider will throw `any Error`.
     - Parameter transform: An `async` block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: An ``AsyncProvider`` that returns values of type `OtherValue` or throws.
     */
    @_disfavoredOverload
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) async throws(OtherFailure) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, any Error> {
        AsyncValueMappingAnyFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct AsyncValueMappingNewFailureAsyncProvider<
    Mapped: AsyncProvider,
    Value,
    ValueMappingError: Error
>: AsyncProvider where Mapped.Failure == Never {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) async throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws(ValueMappingError) -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider where Failure == Never {
    /**
     Asynchronously maps an ``AsyncProvider`` returned values to different ones, possibly throwing an error instead.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: An `async` block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: An ``AsyncProvider`` that returns values of type `OtherValue`.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) async throws(OtherFailure) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, OtherFailure> {
        AsyncValueMappingNewFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

// swiftlint:enable type_name
