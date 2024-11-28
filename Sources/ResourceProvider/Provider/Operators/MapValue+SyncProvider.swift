//
//  MapValue+SyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

// swiftlint:disable type_name

// MARK: - SyncProvider Map Value

private struct ValueMappingNeverFailureSyncProvider<Mapped: SyncProvider, Value>: SyncProvider {
    var mapped: Mapped

    var valueMapper: (Mapped.Value, ID) -> Value

    func value(for id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider {
    /**
     Maps a ``SyncProvider`` returned values to different ones.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A block that translates a returning value to another value of type `OtherValue`. It gets
     both the value and the id that was requested to return it.
     - Returns: A ``SyncProvider`` that returns values of type `OtherValue`.
     */
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> some SyncProvider<ID, OtherValue, Failure> {
        ValueMappingNeverFailureSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingSameFailureSyncProvider<Mapped: SyncProvider, Value>: SyncProvider {
    var mapped: Mapped

    var valueMapper: (Mapped.Value, ID) throws(Mapped.Failure) -> Value

    func value(for id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider {
    /**
     Maps a ``SyncProvider`` returned values to different ones, possibly throwing an error instead.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A block that translates a returning value to another value of type `OtherValue` or throws if
     it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: A ``SyncProvider`` that returns values of type `OtherValue` or throws.
     */
    @_disfavoredOverload
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws(Failure) -> OtherValue
    ) -> some SyncProvider<ID, OtherValue, Failure> {
        ValueMappingSameFailureSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingAnyFailureSyncProvider<Mapped: SyncProvider, Value, ValueMappingError: Error>: SyncProvider {
    var mapped: Mapped

    var valueMapper: (Mapped.Value, ID) throws(ValueMappingError) -> Value

    func value(for id: Mapped.ID) throws -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider {
    /**
     Maps a ``SyncProvider`` returned values to different ones, possibly throwing an error instead.

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
     - Parameter transform: A block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: A ``SyncProvider`` that returns values of type `OtherValue` or throws.
     */
    @_disfavoredOverload
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some SyncProvider<ID, OtherValue, any Error> {
        ValueMappingAnyFailureSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingNewFailureSyncProvider<
    Mapped: SyncProvider,
    Value,
    ValueMappingError: Error
>: SyncProvider where Mapped.Failure == Never {
    var mapped: Mapped

    var valueMapper: (Mapped.Value, ID) throws(ValueMappingError) -> Value

    func value(for id: Mapped.ID) throws(ValueMappingError) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider where Failure == Never {
    /**
     Maps a ``SyncProvider`` returned values to different ones, possibly throwing an error instead.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: A ``SyncProvider`` that returns values of type `OtherValue`.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some SyncProvider<ID, OtherValue, OtherFailure> {
        ValueMappingNewFailureSyncProvider(mapped: self, valueMapper: transform)
    }
}

// MARK: - SyncProvider & Sendable Map Value

private struct ValueMappingNeverFailureSendableSyncProvider<
    Mapped: SyncProvider & Sendable,
    Value
>: SyncProvider & Sendable {
    var mapped: Mapped

    var valueMapper: @Sendable (Mapped.Value, ID) -> Value

    func value(for id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Maps a ``SyncProvider`` returned values to different ones, maintaining sendability.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A `@Sendable` block that translates a returning value to another value of type `OtherValue`.
     It gets both the value and the id that was requested to return it.
     - Returns: A ``SyncProvider`` `& Sendable` that returns values of type `OtherValue`.
     */
    func mapValue<OtherValue>(
        _ transform: @escaping @Sendable (Value, ID) -> OtherValue
    ) -> some SendableSyncProvider<ID, OtherValue, Failure> {
        ValueMappingNeverFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingSameFailureSendableSyncProvider<
    Mapped: SyncProvider & Sendable,
    Value
>: SyncProvider & Sendable {
    var mapped: Mapped

    var valueMapper: @Sendable (Mapped.Value, ID) throws(Mapped.Failure) -> Value

    func value(for id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Maps a ``SyncProvider`` returned values to different ones, possibly throwing an error instead and maintaining
     sendability.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A `@Sendable` block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: A ``SyncProvider`` `& Sendable` that returns values of type `OtherValue` or throws.
     */
    @_disfavoredOverload
    func mapValue<OtherValue>(
        _ transform: @escaping @Sendable (Value, ID) throws(Failure) -> OtherValue
    ) -> some SendableSyncProvider<ID, OtherValue, Failure> {
        ValueMappingSameFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingAnyFailureSendableSyncProvider<
    Mapped: SyncProvider & Sendable,
    Value,
    ValueMappingError: Error
>: SyncProvider & Sendable {
    var mapped: Mapped

    var valueMapper: @Sendable (Mapped.Value, ID) throws(ValueMappingError) -> Value

    func value(for id: Mapped.ID) throws -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Maps a ``SyncProvider`` returned values to different ones, possibly throwing an error instead and maintaining
     sendability.

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
     - Parameter transform: A `@Sendable` block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: A ``SyncProvider`` `& Sendable` that returns values of type `OtherValue` or throws.
     */
    @_disfavoredOverload
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some SendableSyncProvider<ID, OtherValue, any Error> {
        ValueMappingAnyFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingNewFailureSendableSyncProvider<
    Mapped: SyncProvider & Sendable,
    Value,
    ValueMappingError: Error
>: SyncProvider, Sendable where Mapped.Failure == Never {
    var mapped: Mapped

    var valueMapper: @Sendable (Mapped.Value, ID) throws(ValueMappingError) -> Value

    func value(for id: Mapped.ID) throws(ValueMappingError) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider where Self: Sendable, Failure == Never {
    /**
     Maps a ``SyncProvider`` returned values to different ones, possibly throwing an error instead, maintaing
     sendability.

     Use this modifier when the values returned need any processing or transformation, whether into a different type or
     just some kind of modification.

     If there are cases where the `id` is enough to determine whether a different value needs to be returned, use
     ``interject`` for those.

     Note that this won't be called if the modified provider throws. For that you'll need to use ``catch``.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed to the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameter transform: A `@Sendable` block that translates a returning value to another value of type `OtherValue`
     or throws if it cannot do so. It gets both the value and the id that was requested to return it.
     - Returns: A ``SyncProvider`` `& Sendable` that returns values of type `OtherValue`.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some SendableSyncProvider<ID, OtherValue, OtherFailure> {
        ValueMappingNewFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

// swiftlint:enable type_name
