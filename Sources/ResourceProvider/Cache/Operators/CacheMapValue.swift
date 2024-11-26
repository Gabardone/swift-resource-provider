//
//  CacheMapValue.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

private struct ValueMappingSyncCache<Mapped: SyncCache, Value> {
    var mapped: Mapped

    var valueToStorage: (Value, Mapped.ID) -> Mapped.Value?

    var valueFromStorage: (Mapped.Value, Mapped.ID) -> Value?
}

extension ValueMappingSyncCache: SyncCache {
    func value(for id: Mapped.ID) -> Value? {
        mapped.value(for: id).flatMap { mappedValue in
            valueFromStorage(mappedValue, id)
        }
    }

    func store(value: Value, for id: Mapped.ID) {
        if let mappedValue = valueToStorage(value, id) {
            mapped.store(value: mappedValue, for: id)
        }
    }
}

public extension SyncCache {
    /**
     Maps a value type to and from the calling cache's value type.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.
     - Parameters:
       - toStorage: A block that translates a value from `OtherValue` to `Self.Value` so it can be stored by the calling
     cache. It gets both the value and the associated id passed in. If translation is impossible or some other error
     occurs the block can return `nil`
       - fromStorage: A block that translates a cached value to `OtherValue`. It gets both the cached value and the
     associated id passed in. If translation is impossible or some other error occurs the block can return `nil`
     - Returns: A sync cache that takes `OtherValue` as its `Value` type.
     */
    func mapValueToStorage<OtherValue>(
        _ toStorage: @escaping (OtherValue, ID) -> Value?,
        fromStorage: @escaping (Value, ID) -> OtherValue?
    ) -> some SyncCache<ID, OtherValue> {
        ValueMappingSyncCache(mapped: self, valueToStorage: toStorage, valueFromStorage: fromStorage)
    }
}

private struct ValueMappingSendableSyncCache<Mapped: SyncCache & Sendable, Value>: Sendable {
    var mapped: Mapped

    var valueToStorage: @Sendable (Value, Mapped.ID) -> Mapped.Value?

    var valueFromStorage: @Sendable (Mapped.Value, Mapped.ID) -> Value?
}

extension ValueMappingSendableSyncCache: SyncCache {
    func value(for id: Mapped.ID) -> Value? {
        mapped.value(for: id).flatMap { mappedValue in
            valueFromStorage(mappedValue, id)
        }
    }

    func store(value: Value, for id: Mapped.ID) {
        if let mappedValue = valueToStorage(value, id) {
            mapped.store(value: mappedValue, for: id)
        }
    }
}

public extension SyncCache where Self: Sendable {
    /**
     Maps a value type to and from the calling cache's value type.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.

     This is the ``Sendable`` version for easier interaction with ``AsyncCache`` and ``AsyncProvider``. While the
     declaration does not require `ID` to adopt ``Sendable`` in practice you're unlikely to keep the compiler happy
     unless it is.
     - Parameters:
       - toStorage: A block that translates a value from `OtherValue` to `Self.Value` so it can be stored by the calling
     cache. It gets both the value and the associated id passed in. If translation is impossible or some other error
     occurs the block can return `nil`
       - fromStorage: A block that translates a cached value to `OtherValue`. It gets both the cached value and the
     associated id passed in. If translation is impossible or some other error occurs the block can return `nil`
     - Returns: A sync cache that takes `OtherValue` as its `Value` type.
     */
    func mapValueToStorage<OtherValue: Sendable>(
        _ toStorage: @escaping @Sendable (OtherValue, ID) -> Value?,
        fromStorage: @escaping @Sendable (Value, ID) -> OtherValue?
    ) -> some SyncCache<ID, OtherValue> & Sendable {
        ValueMappingSendableSyncCache(mapped: self, valueToStorage: toStorage, valueFromStorage: fromStorage)
    }
}

private struct SyncValueMappingAsyncCache<Mapped: AsyncCache, Value: Sendable> {
    var mapped: Mapped

    var valueToStorage: @Sendable (Value, Mapped.ID) -> Mapped.Value?

    var valueFromStorage: @Sendable (Mapped.Value, Mapped.ID) -> Value?
}

extension SyncValueMappingAsyncCache: AsyncCache {
    func value(for id: Mapped.ID) async -> Value? {
        await mapped.value(for: id).flatMap { storedValue in
            valueFromStorage(storedValue, id)
        }
    }

    func store(value: Value, for id: ID) async {
        if let cacheValue = valueToStorage(value, id) {
            await mapped.store(value: cacheValue, for: id)
        }
    }
}

public extension AsyncCache {
    /**
     Maps a value type to and from the calling async cache's value type.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.

     If the transform functions are synchronous this method will call them synchronously and save one async context jump
     on each direction.
     - Parameters:
       - toStorage: A block that translates a value from `OtherValue` to `Self.Value` so it can be stored by the calling
     cache. It gets both the value and the associated id passed in. If translation is impossible or some other error
     occurs the block can return `nil`
       - fromStorage: A block that translates a cached value to `OtherValue`. It gets both the cached value and the
     associated id passed in. If translation is impossible or some other error occurs the block can return `nil`
     - Returns: A sync cache that takes `OtherValue` as its `Value` type.
     */
    func mapValueToStorage<OtherValue: Sendable>(
        _ toStorage: @escaping @Sendable (OtherValue, ID) -> Value?,
        fromStorage: @escaping @Sendable (Value, ID) -> OtherValue?
    ) -> some AsyncCache<ID, OtherValue> {
        SyncValueMappingAsyncCache(mapped: self, valueToStorage: toStorage, valueFromStorage: fromStorage)
    }
}

private struct AsyncValueMappingAsyncCache<Mapped: AsyncCache, Value: Sendable> {
    var mapped: Mapped

    var valueToStorage: @Sendable (Value, Mapped.ID) async -> Mapped.Value?

    var valueFromStorage: @Sendable (Mapped.Value, Mapped.ID) async -> Value?
}

extension AsyncValueMappingAsyncCache: AsyncCache {
    func value(for id: Mapped.ID) async -> Value? {
        if let storedValue = await mapped.value(for: id) {
            await valueFromStorage(storedValue, id)
        } else {
            nil
        }
    }

    func store(value: Value, for id: ID) async {
        if let cacheValue = await valueToStorage(value, id) {
            await mapped.store(value: cacheValue, for: id)
        }
    }
}

public extension AsyncCache {
    /**
     Maps a value type to and from the calling async cache's value type.

     If you want to map both `ID` and `Value` consider whether the original `ID` or its mapped type will work out better
     for value mapping, since they are passed in the value transform methods for cases where the information the id
     contains is required or helpful for the value transformation.

     Asynchronous value transform methods will require one extra async context jump in either direction, if possible
     stick to synchronous mapping.
     - Parameters:
       - toStorage: A block that translates a value from `OtherValue` to `Self.Value` so it can be stored by the calling
     cache. It gets both the value and the associated id passed in. If translation is impossible or some other error
     occurs the block can return `nil`
       - fromStorage: A block that translates a cached value to `OtherValue`. It gets both the cached value and the
     associated id passed in. If translation is impossible or some other error occurs the block can return `nil`
     - Returns: A sync cache that takes `OtherValue` as its `Value` type.
     */
    func mapValueToStorage<OtherValue: Sendable>(
        _ toStorage: @escaping @Sendable (OtherValue, ID) async -> Value?,
        fromStorage: @escaping @Sendable (Value, ID) async -> OtherValue?
    ) -> some AsyncCache<ID, OtherValue> {
        AsyncValueMappingAsyncCache(mapped: self, valueToStorage: toStorage, valueFromStorage: fromStorage)
    }
}
