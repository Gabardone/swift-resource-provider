//
//  Catch.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

// MARK: - SyncProvider Catching

private struct CatchingSyncProvider<Caught: SyncProvider, Failure: Error>: SyncProvider {
    typealias Catcher = (Caught.Failure, ID) throws(Failure) -> Caught.Value

    var caught: Caught

    var catcher: Catcher

    func value(for id: Caught.ID) throws(Failure) -> Caught.Value {
        do throws(Caught.Failure) {
            return try caught.value(for: id)
        } catch {
            return try catcher(error, id)
        }
    }
}

public extension SyncProvider {
    /**
     Builds a ``SyncProvider`` that catches the exceptions thrown by the calling one.

     This modifier converts a throwing ``SyncProvider`` into one that `throws` differently. The catching block will
     only be called when the root provider `throws` and is in no obligation to `throw` itself (and in fact won't if
     `OtherFailure == Never`) and may filter out errors, perform side effects and return values instead of rethrowing.

     Beyond that the behavior depends on the type of `OtherFailure`:
     - If `OtherFailure == Never` the resulting provider will become a non-throwing one.
     - If `OtherFailure == Failure` the resulting provider may rethrow or `throw` a different error of the same kind.
     - If `OtherFailure == any Error` the resulting provider may throw whatever it wants.
     - If `OtherFailure != Failure` the provider may translate the original provider's errors into a different type.
     - Parameter catcher: A block that gets called when errors are thrown with the error thrown and the `id` requested
     that cause the error to be thrown.
     - Returns: A ``SyncProvider`` that catches the exceptions thrown by the caller and processes them differently.
     */
    func `catch`<OtherFailure: Error>(
        _ catcher: @escaping (Failure, ID) throws(OtherFailure) -> Value
    ) -> some SyncProvider<ID, Value, OtherFailure> {
        CatchingSyncProvider(caught: self, catcher: catcher)
    }
}

// MARK: - SyncProvider & Sendable Catching

private struct CatchingSendableSyncProvider<Caught: SyncProvider & Sendable, Failure: Error>: SyncProvider, Sendable {
    typealias Catcher = @Sendable (Caught.Failure, ID) throws(Failure) -> Caught.Value

    var caught: Caught

    var catcher: Catcher

    func value(for id: Caught.ID) throws(Failure) -> Caught.Value {
        do throws(Caught.Failure) {
            return try caught.value(for: id)
        } catch {
            return try catcher(error, id)
        }
    }
}

public extension SyncProvider where Self: Sendable {
    /**
     Builds a ``SyncProvider`` `& Sendable` that catches the exceptions thrown by the calling one.

     This modifier converts a throwing, ``SyncProvider`` `& Sendable` into one that `throws` differently. The catching
     block will only be called when the root provider `throws` and is in no obligation to `throw` itself (and in fact
     won't if `OtherFailure == Never`) and may filter out errors, perform side effects and return values instead of
     rethrowing.

     Beyond that the behavior depends on the type of `OtherFailure`:
     - If `OtherFailure == Never` the resulting provider will become a non-throwing one.
     - If `OtherFailure == Failure` the resulting provider may rethrow or `throw` a different error of the same kind.
     - If `OtherFailure == any Error` the resulting provider may throw whatever it wants.
     - If `OtherFailure != Failure` the provider may translate the original provider's errors into a different type.

     This version of the modifier maintains sendability so it can be more easily used with ``AsyncProvider`` or in other
     concurrent contexts.
     - Parameter catcher: A block that gets called when errors are thrown with the error thrown and the `id` requested
     that cause the error to be thrown.
     - Returns: A ``SyncProvider`` `& Sendable` that catches the exceptions thrown by the caller and processes them
     differently.
     */
    func `catch`<OtherFailure: Error>(
        _ catcher: @escaping @Sendable (Failure, ID) throws(OtherFailure) -> Value
    ) -> some SyncProvider<ID, Value, OtherFailure> & Sendable {
        CatchingSendableSyncProvider(caught: self, catcher: catcher)
    }
}

// MARK: - AsyncProvider Catching

private struct SyncCatchingAsyncProvider<Caught: AsyncProvider, Failure: Error>: AsyncProvider {
    typealias Catcher = @Sendable (Caught.Failure, ID) throws(Failure) -> Caught.Value

    var caught: Caught

    var catcher: Catcher

    func value(for id: Caught.ID) async throws(Failure) -> Caught.Value {
        do throws(Caught.Failure) {
            return try await caught.value(for: id)
        } catch {
            return try catcher(error, id)
        }
    }
}

public extension AsyncProvider {
    /**
     Builds an ``AsyncProvider`` that synchronously catches the exceptions thrown by the calling one.

     This modifier converts a throwing ``AsyncProvider`` into one that `throws` differently. The catching block
     will only be called when the root provider `throws` and is in no obligation to `throw` itself (and in fact won't if
     `OtherFailure == Never`) and may filter out errors, perform side effects and return values instead of rethrowing.

     Beyond that the behavior depends on the type of `OtherFailure`:
     - If `OtherFailure == Never` the resulting provider will become a non-throwing one.
     - If `OtherFailure == Failure` the resulting provider may rethrow or `throw` a different error of the same kind.
     - If `OtherFailure == any Error` the resulting provider may throw whatever it wants.
     - If `OtherFailure != Failure` the provider may translate the original provider's errors into a different type.

     This version of the modifier manages the exceptions synchonously, avoiding one extra concurrent jump.
     - Parameter catcher: A block that gets called when errors are thrown with the error thrown and the `id` requested
     that cause the error to be thrown.
     - Returns: An ``AsyncProvider`` that synchronously catches the exceptions thrown by the caller and processes them
     differently.
     */
    func `catch`<OtherFailure: Error>(
        _ catcher: @escaping @Sendable (Failure, ID) throws(OtherFailure) -> Value
    ) -> some AsyncProvider<ID, Value, OtherFailure> {
        SyncCatchingAsyncProvider(caught: self, catcher: catcher)
    }
}

private struct AsyncCatchingAsyncProvider<Caught: AsyncProvider, Failure: Error>: AsyncProvider {
    typealias Catcher = @Sendable (Caught.Failure, ID) async throws(Failure) -> Caught.Value

    var caught: Caught

    var catcher: Catcher

    func value(for id: Caught.ID) async throws(Failure) -> Caught.Value {
        do throws(Caught.Failure) {
            return try await caught.value(for: id)
        } catch {
            return try await catcher(error, id)
        }
    }
}

public extension AsyncProvider {
    /**
     Builds an ``AsyncProvider`` that asynchronously catches the exceptions thrown by the calling one.

     This modifier converts a throwing ``AsyncProvider`` into one that `throws` differently. The catching block
     will only be called when the root provider `throws` and is in no obligation to `throw` itself (and in fact won't if
     `OtherFailure == Never`) and may filter out errors, perform side effects and return values instead of rethrowing.

     Beyond that the behavior depends on the type of `OtherFailure`:
     - If `OtherFailure == Never` the resulting provider will become a non-throwing one.
     - If `OtherFailure == Failure` the resulting provider may rethrow or `throw` a different error of the same kind.
     - If `OtherFailure == any Error` the resulting provider may throw whatever it wants.
     - If `OtherFailure != Failure` the provider may translate the original provider's errors into a different type.

     This version of the modifier manages the exceptions asynchonously, `await`-ing the error catch logic.
     - Parameter catcher: An `async` block that gets called when errors are thrown with the error thrown and the `id`
     requested that cause the error to be thrown.
     - Returns: An ``AsyncProvider`` that asynchronously catches the exceptions thrown by the caller and processes them
     differently.
     */
    func `catch`<OtherFailure: Error>(
        _ catcher: @escaping @Sendable (Failure, ID) async throws(OtherFailure) -> Value
    ) -> some AsyncProvider<ID, Value, OtherFailure> {
        AsyncCatchingAsyncProvider(caught: self, catcher: catcher)
    }
}
