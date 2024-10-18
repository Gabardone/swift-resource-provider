//
//  SideEffect.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension SyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect(_ sideEffect: @escaping (Value, ID) throws(Failure) -> Void) -> SyncProvider {
        .init { id throws(Failure) in
            let result = try valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping (Value, ID) throws(OtherFailure) -> Void
    ) -> SyncProvider<ID, Value, any Error> {
        .init { id in
            let result = try valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }
}

public extension SyncProvider where Failure == Never {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @escaping (Value, ID) throws(OtherFailure) -> Void
    ) -> SyncProvider<ID, Value, OtherFailure> {
        .init { id throws(OtherFailure) in
            let result = valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }
}

public extension AsyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect(_ sideEffect: @Sendable @escaping (Value, ID) throws(Failure) -> Void) -> AsyncProvider {
        .init { id throws(Failure) in
            let result = try await valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @Sendable @escaping (Value, ID) throws(OtherFailure) -> Void
    ) -> AsyncProvider<ID, Value, any Error> {
        .init { id in
            let result = try await valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: An asynchronous provider that has the given side effect when returning a value.
     */
    func sideEffect(_ sideEffect: @Sendable @escaping (Value, ID) async throws(Failure) -> Void) -> AsyncProvider {
        .init { id throws(Failure) in
            let result = try await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }

    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @Sendable @escaping (Value, ID) async throws(OtherFailure) -> Void
    ) -> AsyncProvider<ID, Value, any Error> {
        .init { id in
            let result = try await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension AsyncProvider where Failure == Never {
    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @Sendable @escaping (Value, ID) throws(OtherFailure) -> Void
    ) -> AsyncProvider<ID, Value, OtherFailure> {
        .init { id throws(OtherFailure) in
            let result = await valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect<OtherFailure: Error>(
        _ sideEffect: @Sendable @escaping (Value, ID) async throws(OtherFailure) -> Void
    ) -> AsyncProvider<ID, Value, OtherFailure> {
        .init { id throws(OtherFailure) in
            let result = await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}
