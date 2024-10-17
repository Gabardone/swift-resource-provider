//
//  Interject.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension SyncProvider {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) -> Value?) -> SyncProvider {
        .init { id in
            interject(id) ?? valueForID(id)
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingSyncProvider<ID, Value> {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }
}

public extension SyncProvider where ID: Sendable, Value: Sendable {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) async -> Value?) -> AsyncProvider<ID, Value> {
        .init { id in
            await interject(id) ?? valueForID(id)
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }
}

public extension ThrowingSyncProvider {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) -> Value?) -> ThrowingSyncProvider {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingSyncProvider {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }
}

public extension ThrowingSyncProvider where ID: Sendable, Value: Sendable {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) async -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }
}

public extension AsyncProvider {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) -> Value?) -> AsyncProvider {
        .init { id in
            if let result = interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            if let result = try interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) async -> Value?) -> AsyncProvider {
        .init { id in
            if let result = await interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }
}

public extension ThrowingAsyncProvider {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) -> Value?) -> ThrowingAsyncProvider {
        .init { id in
            if let result = interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingAsyncProvider {
        .init { id in
            if let result = try interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) async -> Value?) -> ThrowingAsyncProvider {
        .init { id in
            if let result = await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }
}
