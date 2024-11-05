//
//  CacheSideEffect.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/21/24.
//

// MARK: - SyncCache Side Effects

private struct ValueForSideEffectedSyncCache<Effected: SyncCache>: SyncCache {
    typealias ID = Effected.ID

    typealias Value = Effected.Value

    typealias ValueForSideEffect = (Value?, ID) -> Void

    var sideEffected: Effected

    var valueForSideEffect: ValueForSideEffect?

    func value(for id: ID) -> Value? {
        let result = sideEffected.value(for: id)
        valueForSideEffect?(result, id)
        return result
    }

    func store(value: Value, for id: ID) {
        sideEffected.store(value: value, for: id)
    }
}

public extension SyncCache {
    func valueForSideEffect(sideEffect: @escaping (Value?, ID) -> Void) -> some SyncCache<ID, Value> {
        ValueForSideEffectedSyncCache(sideEffected: self, valueForSideEffect: sideEffect)
    }
}

private struct StoreValueForSideEffectedSyncCache<Effected: SyncCache>: SyncCache {
    typealias ID = Effected.ID

    typealias Value = Effected.Value

    typealias StoreValueForSideEffect = (Value, ID) -> Void

    var sideEffected: Effected

    var storeValueForSideEffect: StoreValueForSideEffect?

    func value(for id: ID) -> Value? {
        sideEffected.value(for: id)
    }

    func store(value: Value, for id: ID) {
        sideEffected.store(value: value, for: id)
        storeValueForSideEffect?(value, id)
    }
}

public extension SyncCache {
    func storeValueForSideEffect(sideEffect: @escaping (Value, ID) -> Void) -> some SyncCache<ID, Value> {
        StoreValueForSideEffectedSyncCache(sideEffected: self, storeValueForSideEffect: sideEffect)
    }
}

// MARK: - SendableSyncCache Side Effects

private struct ValueForSideEffectedSendableSyncCache<Effected: SyncCache & Sendable>: SyncCache, Sendable {
    typealias ID = Effected.ID

    typealias Value = Effected.Value

    typealias ValueForSideEffect = @Sendable (Value?, ID) -> Void

    var sideEffected: Effected

    var valueForSideEffect: ValueForSideEffect?

    func value(for id: ID) -> Value? {
        let result = sideEffected.value(for: id)
        valueForSideEffect?(result, id)
        return result
    }

    func store(value: Value, for id: ID) {
        sideEffected.store(value: value, for: id)
    }
}

public extension SyncCache where Self: Sendable {
    func valueForSideEffect(sideEffect: @escaping @Sendable (Value?, ID) -> Void) -> some SyncCache<ID, Value> {
        ValueForSideEffectedSendableSyncCache(sideEffected: self, valueForSideEffect: sideEffect)
    }
}

// swiftlint:disable:next type_name
private struct StoreValueForSideEffectedSendableSyncCache<Effected: SyncCache & Sendable>: SyncCache, Sendable {
    typealias ID = Effected.ID

    typealias Value = Effected.Value

    typealias StoreValueForSideEffect = @Sendable (Value, ID) -> Void

    var sideEffected: Effected

    var storeValueForSideEffect: StoreValueForSideEffect?

    func value(for id: ID) -> Value? {
        sideEffected.value(for: id)
    }

    func store(value: Value, for id: ID) {
        sideEffected.store(value: value, for: id)
        storeValueForSideEffect?(value, id)
    }
}

public extension SyncCache where Self: Sendable {
    func storeValueForSideEffect(sideEffect: @escaping @Sendable (Value, ID) -> Void) -> some SyncCache<ID, Value> {
        StoreValueForSideEffectedSendableSyncCache(sideEffected: self, storeValueForSideEffect: sideEffect)
    }
}

// MARK: - AsyncCache Sync Side Effects

private struct SyncValueForSideEffectedAsyncCache<Effected: AsyncCache>: AsyncCache {
    typealias ID = Effected.ID

    typealias Value = Effected.Value

    typealias ValueForSideEffect = @Sendable (Value?, ID) -> Void

    var sideEffected: Effected

    var valueForSideEffect: ValueForSideEffect?

    func value(for id: ID) async -> Value? {
        let result = await sideEffected.value(for: id)
        valueForSideEffect?(result, id)
        return result
    }

    func store(value: Value, for id: ID) async {
        await sideEffected.store(value: value, for: id)
    }
}

public extension AsyncCache {
    func valueForSideEffect(sideEffect: @escaping @Sendable (Value?, ID) -> Void) -> some AsyncCache<ID, Value> {
        SyncValueForSideEffectedAsyncCache(sideEffected: self, valueForSideEffect: sideEffect)
    }
}

private struct SyncStoreValueForSideEffectedAsyncCache<Effected: AsyncCache>: AsyncCache {
    typealias ID = Effected.ID

    typealias Value = Effected.Value

    typealias StoreValueForSideEffect = @Sendable (Value, ID) -> Void

    var sideEffected: Effected

    var storeValueForSideEffect: StoreValueForSideEffect?

    func value(for id: ID) async -> Value? {
        await sideEffected.value(for: id)
    }

    func store(value: Value, for id: ID) async {
        await sideEffected.store(value: value, for: id)
        storeValueForSideEffect?(value, id)
    }
}

public extension AsyncCache {
    func storeValueForSideEffect(sideEffect: @escaping @Sendable (Value, ID) -> Void) -> some AsyncCache<ID, Value> {
        SyncStoreValueForSideEffectedAsyncCache(sideEffected: self, storeValueForSideEffect: sideEffect)
    }
}

// MARK: - AsyncCache Async Side Effects

private struct AsyncValueForSideEffectedAsyncCache<Effected: AsyncCache>: AsyncCache {
    typealias ID = Effected.ID

    typealias Value = Effected.Value

    typealias ValueForSideEffect = @Sendable (Value?, ID) async -> Void

    var sideEffected: Effected

    var valueForSideEffect: ValueForSideEffect?

    func value(for id: ID) async -> Value? {
        let result = await sideEffected.value(for: id)
        await valueForSideEffect?(result, id)
        return result
    }

    func store(value: Value, for id: ID) async {
        await sideEffected.store(value: value, for: id)
    }
}

public extension AsyncCache {
    func valueForSideEffect(sideEffect: @escaping @Sendable (Value?, ID) async -> Void) -> some AsyncCache<ID, Value> {
        AsyncValueForSideEffectedAsyncCache(sideEffected: self, valueForSideEffect: sideEffect)
    }
}

private struct AsyncStoreValueForSideEffectedAsyncCache<Effected: AsyncCache>: AsyncCache {
    typealias ID = Effected.ID

    typealias Value = Effected.Value

    typealias StoreValueForSideEffect = @Sendable (Value, ID) async -> Void

    var sideEffected: Effected

    var storeValueForSideEffect: StoreValueForSideEffect?

    func value(for id: ID) async -> Value? {
        await sideEffected.value(for: id)
    }

    func store(value: Value, for id: ID) async {
        await sideEffected.store(value: value, for: id)
        await storeValueForSideEffect?(value, id)
    }
}

public extension AsyncCache {
    func storeValueForSideEffect(
        sideEffect: @escaping @Sendable (Value, ID) -> Void
    ) async -> some AsyncCache<ID, Value> {
        AsyncStoreValueForSideEffectedAsyncCache(sideEffected: self, storeValueForSideEffect: sideEffect)
    }
}
