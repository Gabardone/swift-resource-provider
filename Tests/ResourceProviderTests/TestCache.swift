//
//  TestCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

import ResourceProvider

/// Unlike `AnyCache`, it's a reference type and allows for swapping around the functionality so it can be more
/// readily used in tests.
class TestCache<ID: Hashable, Value> {
    var valueForID: (ID) async -> Value?

    var storeValueForID: (ID, Value) async -> Void

    init(valueForID: @escaping (ID) -> Value?, storeValueForID: @escaping (ID, Value) -> Void) {
        self.valueForID = valueForID
        self.storeValueForID = storeValueForID
    }
}

extension TestCache: AsyncCache {
    func value(for id: ID) async -> Value? {
        await valueForID(id)
    }

    func store(value: Value, id: ID) async {
        await storeValueForID(id, value)
    }
}

extension SyncCache {
    func validated(
        fetchValidation: ((ID, Value?) -> Void)? = nil,
        storeValidation: ((ID, Value) -> Void)? = nil
    ) -> some SyncCache<ID, Value> {
        AnySyncCache { id in
            let result = value(for: id)
            fetchValidation?(id, result)
            return result
        } storeValueForID: { value, id in
            storeValidation?(id, value)
            store(value: value, id: id)
        }
    }
}

extension AsyncCache {
    func validated(
        fetchValidation: ((ID, Value?) -> Void)? = nil,
        storeValidation: ((ID, Value) -> Void)? = nil
    ) -> some AsyncCache<ID, Value> {
        AnyAsyncCache { id in
            let result = await value(for: id)
            fetchValidation?(id, result)
            return result
        } storeValueForID: { value, id in
            storeValidation?(id, value)
            await store(value: value, id: id)
        }
    }
}
