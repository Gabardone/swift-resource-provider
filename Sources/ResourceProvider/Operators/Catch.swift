//
//  Catch.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

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
    ) -> SyncProvider<ID, Value, OtherFailure> {
        SyncProvider<ID, Value, OtherFailure> { id throws(OtherFailure) in
            do throws(Failure) {
                return try valueForID(id)
            } catch {
                return try catcher(error, id)
            }
        }
    }
}

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
        _ catcher: @escaping (Failure, ID) throws(OtherFailure) -> Value
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
        _ catcher: @escaping (Failure, ID) async throws(OtherFailure) -> Value
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
