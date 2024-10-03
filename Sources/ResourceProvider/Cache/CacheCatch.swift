//
//  CacheCatch.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension ThrowingSyncResourceProvider {
    func `catch`(_ catcher: @escaping (Error, ID) -> Value) -> SyncResourceProvider<ID, Value> {
        SyncResourceProvider { id in
            do {
                return try valueForID(id)
            } catch {
                return catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) throws -> Value) -> ThrowingSyncResourceProvider {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return try catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async -> Value) -> AsyncResourceProvider<ID, Value> {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return await catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async throws -> Value) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return try await catcher(error, id)
            }
        }
    }
}

public extension ThrowingAsyncResourceProvider {
    func `catch`(_ catcher: @escaping (Error, ID) -> Value) -> AsyncResourceProvider<ID, Value> {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) throws -> Value) -> ThrowingAsyncResourceProvider {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return try catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async -> Value) -> AsyncResourceProvider<ID, Value> {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return await catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async throws -> Value) -> ThrowingAsyncResourceProvider {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return try await catcher(error, id)
            }
        }
    }
}
