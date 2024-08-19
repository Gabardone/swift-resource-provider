//
//  Map.swift
//  
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

extension SyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some SyncCache<OtherID, Value> {
        AnySyncCache { otherID in
            cachedValueWith(id: transform(otherID))
        }
    }

    func mapValue<OtherValue>(_ transform: @escaping (Value) -> OtherValue) -> some SyncCache<ID, OtherValue> {
        AnySyncCache { id in
            transform(cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value) throws -> OtherValue
    ) -> some ThrowingSyncCache<ID, OtherValue> {
        AnyThrowingSyncCache { id in
            try transform(cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(_ transform: @escaping (Value) async -> OtherValue) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            await transform(cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value) async throws -> OtherValue
    ) -> some ThrowingAsyncCache<ID, OtherValue> {
        AnyThrowingAsyncCache { id in
            try await transform(cachedValueWith(id: id))
        }
    }
}

extension ThrowingSyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some ThrowingSyncCache<OtherID, Value> {
        AnyThrowingSyncCache { otherID in
            try cachedValueWith(id: transform(otherID))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>) -> OtherValue
    ) -> some SyncCache<ID, OtherValue> {
        AnySyncCache { id in
            transform(.init(catching: {
                try cachedValueWith(id: id)
            }))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value) throws -> OtherValue
    ) -> some ThrowingSyncCache<ID, OtherValue> {
        AnyThrowingSyncCache { id in
            try transform(try cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>) throws -> OtherValue
    ) -> some ThrowingSyncCache<ID, OtherValue> {
        AnyThrowingSyncCache { id in
            try transform(.init(catching: {
                try cachedValueWith(id: id)
            }))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>) async -> OtherValue
    ) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            await transform(.init(catching: {
                try cachedValueWith(id: id)
            }))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value) async throws -> OtherValue
    ) -> some ThrowingAsyncCache<ID, OtherValue> {
        AnyThrowingAsyncCache { id in
            try await transform(try cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>) async throws -> OtherValue
    ) -> some ThrowingAsyncCache<ID, OtherValue> {
        AnyThrowingAsyncCache { id in
            try await transform(.init(catching: {
                try cachedValueWith(id: id)
            }))
        }
    }
}

extension AsyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some AsyncCache<OtherID, Value> {
        AnyAsyncCache { otherID in
            await cachedValueWith(id: transform(otherID))
        }
    }

    func mapValue<OtherValue>(_ transform: @escaping (Value) -> OtherValue) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            transform(await cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value) throws -> OtherValue
    ) -> some ThrowingAsyncCache<ID, OtherValue> {
        AnyThrowingAsyncCache { id in
            try transform(await cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(_ transform: @escaping (Value) async -> OtherValue) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            await transform(await cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value) async throws -> OtherValue
    ) -> some ThrowingAsyncCache<ID, OtherValue> {
        AnyThrowingAsyncCache { id in
            try await transform(await cachedValueWith(id: id))
        }
    }
}

extension ThrowingAsyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some ThrowingAsyncCache<OtherID, Value> {
        AnyThrowingAsyncCache { otherID in
            try await cachedValueWith(id: transform(otherID))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>) -> OtherValue
    ) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            return transform(await .init(catching: {
                try await cachedValueWith(id: id)
            }))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value) throws -> OtherValue
    ) -> some ThrowingAsyncCache<ID, OtherValue> {
        AnyThrowingAsyncCache { id in
            try transform(try await cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>) throws -> OtherValue
    ) -> some ThrowingAsyncCache<ID, OtherValue> {
        AnyThrowingAsyncCache { id in
            return try transform(await .init(catching: {
                try await cachedValueWith(id: id)
            }))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>) async -> OtherValue
    ) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            return await transform(await .init(catching: {
                try await cachedValueWith(id: id)
            }))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value) async throws -> OtherValue
    ) -> some ThrowingAsyncCache<ID, OtherValue> {
        AnyThrowingAsyncCache { id in
            try await transform(try cachedValueWith(id: id))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>) async throws -> OtherValue
    ) -> some ThrowingAsyncCache<ID, OtherValue> {
        AnyThrowingAsyncCache { id in
            try await transform(await .init(catching: {
                try await cachedValueWith(id: id)
            }))
        }
    }
}

private extension Result where Failure == Error {
    init(catching body: () async throws -> Success) async {
        do {
            self = .success(try await body())
        } catch {
            self = .failure(error)
        }
    }
}
