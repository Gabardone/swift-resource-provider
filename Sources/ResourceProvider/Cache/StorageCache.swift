//
//  StorageCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncProvider {
    func storage(_ storage: some SyncCache<ID, Value>) -> SyncProvider {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncCache<ID, Value>) -> AsyncProvider<ID, Value> {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}

public extension ThrowingSyncProvider {
    func storage(_ storage: some SyncCache<ID, Value>) -> ThrowingSyncProvider {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncCache<ID, Value>) -> ThrowingAsyncProvider<ID, Value> {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}

public extension AsyncProvider {
    func storage(_ storage: some SyncCache<ID, Value>) -> AsyncProvider {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncCache<ID, Value>) -> AsyncProvider {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}

public extension ThrowingAsyncProvider {
    func storage(_ storage: some SyncCache<ID, Value>) -> ThrowingAsyncProvider {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncCache<ID, Value>) -> ThrowingAsyncProvider {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}