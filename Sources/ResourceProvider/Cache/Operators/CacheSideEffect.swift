//
//  CacheSideEffect.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

// MARK: - SyncCache Side Effects

private struct ValueForSideEffectedSyncCache<Effected: SyncCache> {
    var sideEffected: Effected

    var valueForSideEffect: (Value?, ID) -> Void
}

extension ValueForSideEffectedSyncCache: SyncCache {
    func value(for id: Effected.ID) -> Effected.Value? {
        let result = sideEffected.value(for: id)
        valueForSideEffect(result, id)
        return result
    }

    func store(value: Effected.Value, for id: Effected.ID) {
        sideEffected.store(value: value, for: id)
    }
}

public extension SyncCache {
    /**
     Applies a side effect when retrieving a value from the calling ``SyncCache``.

     The side effect is applied _after_ the retrieval, and it is passed both the retrieved value and the id used to do
     so.
     - Parameter sideEffect: A side effect that will be invoked when a value is retrieved from the cache, with that
     value and the id used to fetch it as parameters.
     - Returns: a cache that acts just like the caller but also has a side effect on value retrieval.
     */
    func valueForSideEffect(sideEffect: @escaping (Value?, ID) -> Void) -> some SyncCache<ID, Value> {
        ValueForSideEffectedSyncCache(sideEffected: self, valueForSideEffect: sideEffect)
    }
}

private struct StoreValueForSideEffectedSyncCache<Effected: SyncCache> {
    var sideEffected: Effected

    var storeValueForSideEffect: (Effected.Value, Effected.ID) -> Void
}

extension StoreValueForSideEffectedSyncCache: SyncCache {
    func value(for id: Effected.ID) -> Effected.Value? {
        sideEffected.value(for: id)
    }

    func store(value: Effected.Value, for id: Effected.ID) {
        sideEffected.store(value: value, for: id)
        storeValueForSideEffect(value, id)
    }
}

public extension SyncCache {
    /**
     Applies a side effect when storing a value in the calling ``SyncCache``.

     The side effect is applied _after_ the storage, and it is passed both the stored value and the id for that value.
     - Parameter sideEffect: A side effect that will be invoked right after a value is stored into the cache, with that
     value and the id used to store it as parameters.
     - Returns: a cache that acts just like the caller but also has a side effect on value storage.
     */
    func storeValueForSideEffect(sideEffect: @escaping (Value, ID) -> Void) -> some SyncCache<ID, Value> {
        StoreValueForSideEffectedSyncCache(sideEffected: self, storeValueForSideEffect: sideEffect)
    }
}

// MARK: - SendableSyncCache Side Effects

private struct ValueForSideEffectedSendableSyncCache<Effected: SyncCache & Sendable>: Sendable {
    var sideEffected: Effected

    var valueForSideEffect: @Sendable (Effected.Value?, Effected.ID) -> Void?
}

extension ValueForSideEffectedSendableSyncCache: SyncCache {
    func value(for id: Effected.ID) -> Effected.Value? {
        let result = sideEffected.value(for: id)
        valueForSideEffect(result, id)
        return result
    }

    func store(value: Effected.Value, for id: Effected.ID) {
        sideEffected.store(value: value, for: id)
    }
}

public extension SyncCache where Self: Sendable {
    /**
     Applies a side effect when retrieving a value from the calling `Sendable` ``SyncCache``.

     The side effect is applied _after_ the retrieval, and it is passed both the retrieved value and the id used to do
     so.

     While the declaration requires neither `ID` nor `Value` to be `Sendable`, in practice they'll almost always have to
     be.
     - Parameter sideEffect: A side effect that will be invoked when a value is retrieved from the cache, with that
     value and the id used to fetch it as parameters.
     - Returns: a cache that acts just like the caller but also has a side effect on value retrieval.
     */
    func valueForSideEffect(
        sideEffect: @escaping @Sendable (Value?, ID) -> Void
    ) -> some SyncCache<ID, Value> & Sendable {
        ValueForSideEffectedSendableSyncCache(sideEffected: self, valueForSideEffect: sideEffect)
    }
}

// swiftlint:disable:next type_name
private struct StoreValueForSideEffectedSendableSyncCache<Effected: SyncCache & Sendable>: Sendable {
    var sideEffected: Effected

    var storeValueForSideEffect: @Sendable (Effected.Value, Effected.ID) -> Void
}

extension StoreValueForSideEffectedSendableSyncCache: SyncCache {
    func value(for id: Effected.ID) -> Effected.Value? {
        sideEffected.value(for: id)
    }

    func store(value: Effected.Value, for id: Effected.ID) {
        sideEffected.store(value: value, for: id)
        storeValueForSideEffect(value, id)
    }
}

public extension SyncCache where Self: Sendable {
    /**
     Applies a side effect when storing a value in the calling `Sendable` ``SyncCache``.

     The side effect is applied _after_ the storage, and it is passed both the stored value and the id for that value.

     While the declaration requires neither `ID` nor `Value` to be `Sendable`, in practice they'll almost always have to
     be.
     - Parameter sideEffect: A side effect that will be invoked right after a value is stored into the cache, with that
     value and the id used to store it as parameters.
     - Returns: a cache that acts just like the caller but also has a side effect on value storage.
     */

    func storeValueForSideEffect(
        sideEffect: @escaping @Sendable (Value, ID) -> Void
    ) -> some SyncCache<ID, Value> & Sendable {
        StoreValueForSideEffectedSendableSyncCache(sideEffected: self, storeValueForSideEffect: sideEffect)
    }
}

// MARK: - AsyncCache Sync Side Effects

private struct SyncValueForSideEffectedAsyncCache<Effected: AsyncCache> {
    var sideEffected: Effected

    var valueForSideEffect: @Sendable (Effected.Value?, Effected.ID) -> Void
}

extension SyncValueForSideEffectedAsyncCache: AsyncCache {
    func value(for id: Effected.ID) async -> Effected.Value? {
        let result = await sideEffected.value(for: id)
        valueForSideEffect(result, id)
        return result
    }

    func store(value: Value, for id: ID) async {
        await sideEffected.store(value: value, for: id)
    }
}

public extension AsyncCache {
    /**
     Applies a synchronous side effect when retrieving a value from the calling ``AsyncCache``.

     The side effect is applied _after_ the retrieval, and it is passed both the retrieved value and the id used to do
     so.
     - Parameter sideEffect: A side effect that will be invoked when a value is retrieved from the cache, with that
     value and the id used to fetch it as parameters.
     - Returns: a cache that acts just like the caller but also has a side effect on value retrieval.
     */
    func valueForSideEffect(sideEffect: @escaping @Sendable (Value?, ID) -> Void) -> some AsyncCache<ID, Value> {
        SyncValueForSideEffectedAsyncCache(sideEffected: self, valueForSideEffect: sideEffect)
    }
}

private struct SyncStoreValueForSideEffectedAsyncCache<Effected: AsyncCache> {
    var sideEffected: Effected

    var storeValueForSideEffect: @Sendable (Effected.Value, Effected.ID) -> Void
}

extension SyncStoreValueForSideEffectedAsyncCache: AsyncCache {
    func value(for id: Effected.ID) async -> Effected.Value? {
        await sideEffected.value(for: id)
    }

    func store(value: Effected.Value, for id: Effected.ID) async {
        await sideEffected.store(value: value, for: id)
        storeValueForSideEffect(value, id)
    }
}

public extension AsyncCache {
    /**
     Applies a synchronous side effect when storing a value in the calling ``AsyncCache``.

     The side effect is applied _after_ the storage, and it is passed both the stored value and the id for that value.
     - Parameter sideEffect: A side effect that will be invoked right after a value is stored into the cache, with that
     value and the id used to store it as parameters.
     - Returns: a cache that acts just like the caller but also has a side effect on value storage.
     */
    func storeValueForSideEffect(sideEffect: @escaping @Sendable (Value, ID) -> Void) -> some AsyncCache<ID, Value> {
        SyncStoreValueForSideEffectedAsyncCache(sideEffected: self, storeValueForSideEffect: sideEffect)
    }
}

// MARK: - AsyncCache Async Side Effects

private struct AsyncValueForSideEffectedAsyncCache<Effected: AsyncCache> {
    var sideEffected: Effected

    var valueForSideEffect: @Sendable (Effected.Value?, Effected.ID) async -> Void
}

extension AsyncValueForSideEffectedAsyncCache: AsyncCache {
    func value(for id: Effected.ID) async -> Effected.Value? {
        let result = await sideEffected.value(for: id)
        await valueForSideEffect(result, id)
        return result
    }

    func store(value: Effected.Value, for id: Effected.ID) async {
        await sideEffected.store(value: value, for: id)
    }
}

public extension AsyncCache {
    /**
     Applies an asynchronous side effect when retrieving a value from the calling ``AsyncCache``.

     The side effect is applied _after_ the retrieval, and it is passed both the retrieved value and the id used to do
     so.
     - Parameter sideEffect: A side effect that will be invoked when a value is retrieved from the cache, with that
     value and the id used to fetch it as parameters.
     - Returns: a cache that acts just like the caller but also has a side effect on value retrieval.
     */
    func valueForSideEffect(sideEffect: @escaping @Sendable (Value?, ID) async -> Void) -> some AsyncCache<ID, Value> {
        AsyncValueForSideEffectedAsyncCache(sideEffected: self, valueForSideEffect: sideEffect)
    }
}

private struct AsyncStoreValueForSideEffectedAsyncCache<Effected: AsyncCache> {
    var sideEffected: Effected

    var storeValueForSideEffect: @Sendable (Effected.Value, Effected.ID) async -> Void
}

extension AsyncStoreValueForSideEffectedAsyncCache: AsyncCache {
    func value(for id: Effected.ID) async -> Effected.Value? {
        await sideEffected.value(for: id)
    }

    func store(value: Effected.Value, for id: Effected.ID) async {
        await sideEffected.store(value: value, for: id)
        await storeValueForSideEffect(value, id)
    }
}

public extension AsyncCache {
    /**
     Applies an asynchronous side effect when storing a value in the calling ``AsyncCache``.

     The side effect is applied _after_ the storage, and it is passed both the stored value and the id for that value.
     - Parameter sideEffect: A side effect that will be invoked right after a value is stored into the cache, with that
     value and the id used to store it as parameters.
     - Returns: a cache that acts just like the caller but also has a side effect on value storage.
     */
    func storeValueForSideEffect(
        sideEffect: @escaping @Sendable (Value, ID) -> Void
    ) async -> some AsyncCache<ID, Value> {
        AsyncStoreValueForSideEffectedAsyncCache(sideEffected: self, storeValueForSideEffect: sideEffect)
    }
}
