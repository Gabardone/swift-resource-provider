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

    func valueFor(id: Caught.ID) throws(Failure) -> Caught.Value {
        do throws(Caught.Failure) {
            return try caught.valueFor(id: id)
        } catch {
            return try catcher(error, id)
        }
    }
}

public extension SyncProvider {
    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing sync provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to return a value.
     - Parameter catcher: A block that gets errors thrown and returns a new value. The id for the requested value that
     caused the exception is also passed in.
     - Returns: A sync provider that catches the exceptions thrown by the caller.
     */
    func `catch`<OtherFailure: Error>(
        _ catcher: @escaping (Failure, ID) throws(OtherFailure) -> Value
    ) -> some SyncProvider<ID, Value, OtherFailure> {
        CatchingSyncProvider(caught: self, catcher: catcher)
    }
}

// MARK: - Sendable SyncProvider Catching

private struct CatchingSendableSyncProvider<Caught: SyncProvider & Sendable, Failure: Error>: SyncProvider, Sendable {
    typealias Catcher = @Sendable (Caught.Failure, ID) throws(Failure) -> Caught.Value

    var caught: Caught

    var catcher: Catcher

    func valueFor(id: Caught.ID) throws(Failure) -> Caught.Value {
        do throws(Caught.Failure) {
            return try caught.valueFor(id: id)
        } catch {
            return try catcher(error, id)
        }
    }
}

public extension SyncProvider where Self: Sendable {
    func `catch`<OtherFailure: Error>(
        _ catcher: @Sendable @escaping (Failure, ID) throws(OtherFailure) -> Value
    ) -> some SyncProvider<ID, Value, OtherFailure> & Sendable {
        CatchingSendableSyncProvider(caught: self, catcher: catcher)
    }
}

// MARK: - AsyncProvider Catching

public extension AsyncProvider {
    /**
     Builds a provider that catches the exceptions thrown by the calling one.

     This modifier converts a throwing async provider into a non-throwing one. The catching block will only be called
     when the root provider throws an exception and will need to return a value.
     - Parameter catcher: A block that gets errors thrown and returns a new value. The id for the requested value that
     caused the exception is also passed in.
     - Returns: An async provider that catches the exceptions thrown by the caller.
     */
    func `catch`<OtherFailure: Error>(
        _ catcher: @Sendable @escaping (Failure, ID) throws(OtherFailure) -> Value
    ) -> AsyncProvider<ID, Value, OtherFailure> {
        AsyncProvider<ID, Value, OtherFailure> { id throws(OtherFailure) in
            do throws(Failure) {
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
    func `catch`<OtherFailure: Error>(
        _ catcher: @Sendable @escaping (Failure, ID) async throws(OtherFailure) -> Value
    ) -> AsyncProvider<ID, Value, OtherFailure> {
        .init { id throws(OtherFailure) in
            do throws(Failure) {
                return try await valueForID(id)
            } catch {
                return try await catcher(error, id)
            }
        }
    }
}
