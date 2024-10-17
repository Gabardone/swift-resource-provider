//
//  Catch.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension ThrowingSyncProvider {
    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing sync provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to return a value.
     - Parameter catcher: A block that gets errors thrown and returns a new value. The id for the requested value that
     caused the exception is also passed in.
     - Returns: A sync provider that catches the exceptions thrown by the caller.
     */
    func `catch`(_ catcher: @escaping (Error, ID) -> Value) -> SyncProvider<ID, Value> {
        SyncProvider { id in
            do {
                return try valueForID(id)
            } catch {
                return catcher(error, id)
            }
        }
    }

    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing sync provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to either return a value, rethrow or throw a new error.
     - Parameter catcher: A block that gets errors thrown and returns a new value or throws. The id for the requested
     value that caused the exception is also passed in.
     - Returns: A sync provider that catches the exceptions thrown by the caller.
     */
    func `catch`(_ catcher: @escaping (Error, ID) throws -> Value) -> ThrowingSyncProvider {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return try catcher(error, id)
            }
        }
    }
}

public extension ThrowingSyncProvider where ID: Sendable, Value: Sendable {
    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing sync provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to return a value.

     This method necessarily converts a synchronous provider into an asynchronous one.
     - Parameter catcher: A block that gets errors thrown and returns a new value. The id for the requested value that
     caused the exception is also passed in.
     - Returns: An async provider that catches the exceptions thrown by the caller.
     */
    func `catch`(_ catcher: @escaping (Error, ID) async -> Value) -> AsyncProvider<ID, Value> {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return await catcher(error, id)
            }
        }
    }

    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing sync provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to either return a value, rethrow or throw a new error.

     This method necessarily converts a synchronous provider into an asynchronous one.
          - Parameter catcher: A block that gets errors thrown and returns a new value or throws. The id for the
     requested value that caused the exception is also passed in.
     - Returns: An async provider that catches the exceptions thrown by the caller.
     */
    func `catch`(_ catcher: @escaping (Error, ID) async throws -> Value) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return try await catcher(error, id)
            }
        }
    }
}

public extension ThrowingAsyncProvider {
    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing async provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to return a value.
     - Parameter catcher: A block that gets errors thrown and returns a new value. The id for the requested value that
     caused the exception is also passed in.
     - Returns: An async provider that catches the exceptions thrown by the caller.
     */
    func `catch`(_ catcher: @escaping (Error, ID) -> Value) -> AsyncProvider<ID, Value> {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return catcher(error, id)
            }
        }
    }

    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing async provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to either return a value, rethrow or throw a new error.
     - Parameter catcher: A block that gets errors thrown and returns a new value or throws. The id for the requested
     value that caused the exception is also passed in.
     - Returns: An async provider that catches the exceptions thrown by the caller.
     */
    func `catch`(_ catcher: @escaping (Error, ID) throws -> Value) -> ThrowingAsyncProvider {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return try catcher(error, id)
            }
        }
    }

    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing async provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to return a value.
     - Parameter catcher: A block that gets errors thrown and returns a new value. The id for the requested value that
     caused the exception is also passed in.
     - Returns: An async provider that catches the exceptions thrown by the caller.
     */
    func `catch`(_ catcher: @escaping (Error, ID) async -> Value) -> AsyncProvider<ID, Value> {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return await catcher(error, id)
            }
        }
    }

    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing async provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to either return a value, rethrow or throw a new error.
     - Parameter catcher: A block that gets errors thrown and returns a new value or throws. The id for the requested
     value that caused the exception is also passed in.
     - Returns: An async provider that catches the exceptions thrown by the caller.
     */
    func `catch`(_ catcher: @escaping (Error, ID) async throws -> Value) -> ThrowingAsyncProvider {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return try await catcher(error, id)
            }
        }
    }
}
