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

    func valueFor(id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.valueFor(id: id), id)
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

    func valueFor(id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.valueFor(id: id), id)
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

    func valueFor(id: Mapped.ID) throws -> Value {
        try valueMapper(mapped.valueFor(id: id), id)
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

    func valueFor(id: Mapped.ID) throws(ValueMappingError) -> Value {
        try valueMapper(mapped.valueFor(id: id), id)
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
    Mapped: SyncProvider & Sendable,
    Value
>: SyncProvider & Sendable {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func valueFor(id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.valueFor(id: id), id)
    }
}

public extension SyncProvider where Self: Sendable {
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
    ) -> some SyncProvider<ID, OtherValue, Failure> & Sendable {
        ValueMappingNeverFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingSameFailureSendableSyncProvider<
    Mapped: SyncProvider & Sendable,
    Value
>: SyncProvider & Sendable {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(Mapped.Failure) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func valueFor(id: Mapped.ID) throws(Mapped.Failure) -> Value {
        try valueMapper(mapped.valueFor(id: id), id)
    }
}

public extension SyncProvider where Self: Sendable {
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
    ) -> some SyncProvider<ID, OtherValue, Failure> & Sendable where OtherFailure == Failure {
        ValueMappingSameFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingAnyFailureSendableSyncProvider<
    Mapped: SyncProvider & Sendable,
    Value,
    ValueMappingError: Error
>: SyncProvider & Sendable {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func valueFor(id: Mapped.ID) throws -> Value {
        try valueMapper(mapped.valueFor(id: id), id)
    }
}

public extension SyncProvider where Self: Sendable {
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
    ) -> some SyncProvider<ID, OtherValue, any Error> & Sendable {
        ValueMappingAnyFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

private struct ValueMappingNewFailureSendableSyncProvider<
    Mapped: SyncProvider & Sendable,
    Value,
    ValueMappingError: Error
>: SyncProvider & Sendable where Mapped.Failure == Never {
    typealias ValueMapper = @Sendable (Mapped.Value, ID) throws(ValueMappingError) -> Value

    var mapped: Mapped

    var valueMapper: ValueMapper

    func valueFor(id: Mapped.ID) throws(ValueMappingError) -> Value {
        try valueMapper(mapped.valueFor(id: id), id)
    }
}

public extension SyncProvider where Self: Sendable, Failure == Never {
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
    ) -> some SyncProvider<ID, OtherValue, OtherFailure> & Sendable {
        ValueMappingNewFailureSendableSyncProvider(mapped: self, valueMapper: transform)
    }
}

// MARK: - AsyncProvider Map Value

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
        _ transform: @Sendable @escaping (Value, ID) throws(Failure) -> OtherValue
    ) -> AsyncProvider<ID, OtherValue, Failure> {
        .init { id throws(Failure) in
            try await transform(valueForID(id), id)
        }
    }

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
        _ transform: @Sendable @escaping (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> AsyncProvider<ID, OtherValue, any Error> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

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
        _ transform: @Sendable @escaping (Value, ID) async throws(Failure) -> OtherValue
    ) -> AsyncProvider<ID, OtherValue, Failure> {
        .init { id throws(Failure) in
            try await transform(valueForID(id), id)
        }
    }

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
        _ transform: @Sendable @escaping (Value, ID) async throws(OtherFailure) -> OtherValue
    ) -> AsyncProvider<ID, OtherValue, any Error> {
        .init { id in
            try await transform(valueForID(id), id)
        }
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
        _ transform: @Sendable @escaping (Value, ID) throws(OtherFailure) -> OtherValue
    ) -> AsyncProvider<ID, OtherValue, OtherFailure> {
        .init { id throws(OtherFailure) in
            try await transform(valueForID(id), id)
        }
    }

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
        _ transform: @Sendable @escaping (Value, ID) async throws(OtherFailure) -> OtherValue
    ) -> AsyncProvider<ID, OtherValue, OtherFailure> {
        .init { id throws(OtherFailure) in
            try await transform(valueForID(id), id)
        }
    }
}
