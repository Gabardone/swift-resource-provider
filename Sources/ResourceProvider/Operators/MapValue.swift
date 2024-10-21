//
//  MapValue.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

// MARK: - SyncProvider Map Value

private struct ValueMappingNeverFailureSyncProvider<Mapped: SyncProvider, Value>: SyncProvider {
    typealias ValueMapper = (Mapped.Value, ID) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> some SyncProvider<ID, OtherValue, Failure> {
        ValueMappingNeverFailureSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingSameFailureSyncProvider<Mapped: SyncProvider, Value>: SyncProvider {
    typealias ValueMapper = (Mapped.Value, ID) throws(Mapped.Failure) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some SyncProvider<ID, OtherValue, Failure> where OtherFailure == Failure {
        ValueMappingSameFailureSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingAnyFailureSyncProvider<Mapped: SyncProvider, Value, ValueMappingError: Error>: SyncProvider {
    typealias ValueMapper = (Mapped.Value, ID) throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) throws -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.

     If the given `transform` block throws the provider itself will throw as well.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
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
    typealias ValueMapper = (Mapped.Value, ID) throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) throws(ValueMappingError) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SyncProvider where Failure == Never {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.

     If the given `transform` block throws the provider itself will throw as well.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some SyncProvider<ID, OtherValue, OtherFailure> {
        ValueMappingNewFailureSyncProvider(mapped: self, valueMapper: transform)
    }
}

// MARK: - Sendable SyncProvider Map Value

private struct ValueMappingNeverFailureSendableSyncProvider<
    Mapped: SendableSyncProvider,
    Value
>: SendableSyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SendableSyncProvider {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue>(
        _ transform: @escaping @Sendable (Value, ID) -> OtherValue
    ) -> some SendableSyncProvider<ID, OtherValue, Failure> {
        ValueMappingNeverFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingSameFailureSendableSyncProvider<
    Mapped: SendableSyncProvider,
    Value
>: SendableSyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(Mapped.Failure) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SendableSyncProvider {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some SendableSyncProvider<ID, OtherValue, Failure> where OtherFailure == Failure {
        ValueMappingSameFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingAnyFailureSendableSyncProvider<
    Mapped: SendableSyncProvider,
    Value,
    ValueMappingError: Error
>: SendableSyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) throws -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SendableSyncProvider {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.

     If the given `transform` block throws the provider itself will throw as well.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some SendableSyncProvider<ID, OtherValue, any Error> {
        ValueMappingAnyFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingNewFailureSendableSyncProvider<
    Mapped: SendableSyncProvider,
    Value,
    ValueMappingError: Error
>: SendableSyncProvider where Mapped.Failure == Never {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) throws(ValueMappingError) -> Value {
        try valueMapper(mapped.value(for: id), id)
    }
}

public extension SendableSyncProvider where Failure == Never {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.

     If the given `transform` block throws the provider itself will throw as well.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some SendableSyncProvider<ID, OtherValue, OtherFailure> {
        ValueMappingNewFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

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
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
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
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, Failure> where OtherFailure == Failure {
        SyncValueMappingSameFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct SyncValueMappingAnyFailureAsyncProvider<Mapped: AsyncProvider, Value, ValueMappingError: Error>: AsyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.

     If the given `transform` block throws the provider itself will throw as well.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
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
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.

     If the given `transform` block throws the provider itself will throw as well.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
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
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
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
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) async throws(OtherFailure) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, Failure> where OtherFailure == Failure {
        AsyncValueMappingSameFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct AsyncValueMappingAnyFailureAsyncProvider<Mapped: AsyncProvider, Value, ValueMappingError: Error>: AsyncProvider {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) async throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func value(for id: Mapped.ID) async throws -> Value {
        try await valueMapper(mapped.value(for: id), id)
    }
}

public extension AsyncProvider {
    /**
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.

     If the given `transform` block throws the provider itself will throw as well.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
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
     Maps the calling provider's `Value` type to a different type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.

     If the given `transform` block throws the provider itself will throw as well.
     - Parameter transform: A block that translates a value of type `Self.Value` to `OtherValue`. It gets both the value
     and the associated id passed in. If translation is impossible or some other error occurs the block can return.
     `nil`.
     - Returns: A provider that returns `OtherValue` as its value type.
     */
    func mapValue<OtherValue, OtherFailure: Error>(
        _ transform: @escaping @Sendable (Value, ID) async throws(OtherFailure) -> OtherValue
    ) -> some AsyncProvider<ID, OtherValue, OtherFailure> {
        AsyncValueMappingNewFailureAsyncProvider(mapped: self, valueMapper: transform)
    }
}
