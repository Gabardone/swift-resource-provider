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
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> SyncProvider {
        .init { id in
            let result = valueForID(id)
            sideEffect(result, id)
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
    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingSyncProvider<ID, Value> {
        .init { id in
            let result = valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }
}

public extension SyncProvider where ID: Sendable, Value: Sendable {
    /**
     Runs an asynchronous side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.

     The method necessarily converts the synchronous provider into an asynchronous one.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: An asynchronous provider that has the given side effect when returning a value.
     */
    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> AsyncProvider<ID, Value> {
        .init { id in
            let result = valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.

     The method necessarily converts the synchronous provider into an asynchronous one.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension ThrowingSyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> ThrowingSyncProvider {
        .init { id in
            let result = try valueForID(id)
            sideEffect(result, id)
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
    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingSyncProvider {
        .init { id in
            let result = try valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }
}

public extension ThrowingSyncProvider where ID: Sendable, Value: Sendable {
    /**
     Runs an asynchronous side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.

     The method necessarily converts the synchronous provider into an asynchronous one.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: An asynchronous provider that has the given side effect when returning a value.
     */
    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = try valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    /**
     Runs a side effect with the returned value and id that may `throw`.

     Unlike the regular method, this one will cause the provider to throw if the passed in block does so. Its use is
     not recommended in general but it might prove useful in specific cases.

     The method necessarily converts the synchronous provider into an asynchronous one.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants. If it throws, the provider throws.
     - Returns: A provider that has the given side effect when returning a value and may also `throw`.
     */
    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = try valueForID(id)
            try await sideEffect(result, id)
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
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> AsyncProvider {
        .init { id in
            let result = await valueForID(id)
            sideEffect(result, id)
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
    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = await valueForID(id)
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
    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> AsyncProvider {
        .init { id in
            let result = await valueForID(id)
            await sideEffect(result, id)
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
    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension ThrowingAsyncProvider {
    /**
     Runs a side effect with the returned value and id.

     This is an easy way to inject side effects into a provider's work. Examples would be logging, testing validation,
     or storing returned values into a cache.
     - Parameter sideEffect: A block that takes the value returned for a given id —also passed in— and can do whatever
     it wants.
     - Returns: A provider that has the given side effect when returning a value.
     */
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> ThrowingAsyncProvider {
        .init { id in
            let result = try await valueForID(id)
            sideEffect(result, id)
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
    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingAsyncProvider {
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
    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> ThrowingAsyncProvider {
        .init { id in
            let result = try await valueForID(id)
            await sideEffect(result, id)
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
    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = try await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}
