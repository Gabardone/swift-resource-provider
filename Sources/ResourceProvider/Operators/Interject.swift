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
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) throws(Failure) -> Value?) -> Self {
        .init { id throws(Failure) in
            if let interjection = try interject(id) {
                interjection
            } else {
                try valueForID(id)
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
    func interject<OtherFailure: Error>(
        _ interject: @escaping (ID) throws(OtherFailure) -> Value?
    ) -> SyncProvider<ID, Value, any Error> {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }
}

extension SyncProvider where Failure == Never {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping (ID) throws(OtherFailure) -> Value?
    ) -> SyncProvider<ID, Value, OtherFailure> {
        .init { id throws(OtherFailure) in
            try interject(id) ?? valueForID(id)
        }
    }
}

public extension AsyncProvider {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject(_ interject: @escaping (ID) throws(Failure) -> Value?) -> Self {
        .init { id throws(Failure) in
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
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping (ID) throws(OtherFailure) -> Value?
    ) -> AsyncProvider<ID, Value, any Error> {
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
    func interject(_ interject: @escaping (ID) async throws(Failure) -> Value?) -> AsyncProvider {
        .init { id throws(Failure) in
            if let result = try await interject(id) {
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
    func interject<OtherFailure: Error>(
        _ interject: @escaping (ID) async throws(OtherFailure) -> Value?
    ) -> AsyncProvider<ID, Value, any Error> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }
}

public extension AsyncProvider where Failure == Never {
    /**
     Allows for optionally intercepting a request for an `id` and returning something different.

     The block will be called before calling further into the provider chain and if the block returns a non-`nil` value
     it will return that instead of calling in further. If it throws it will also skip calling further in as well.

     If the block returns `nil` then the provider will continue as expected.
     - Parameter interject: A block that takes an `id` and either returns a value or `nil`
     - Returns: A provider that allows the given block to take first dibs at returning a value for any given `id`.
     */
    func interject<OtherFailure: Error>(
        _ interject: @escaping (ID) throws(OtherFailure) -> Value?
    ) -> AsyncProvider<ID, Value, OtherFailure> {
        .init { id throws(OtherFailure) in
            if let interjected = try interject(id) {
                interjected
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
    func interject<OtherFailure: Error>(
        _ interject: @escaping (ID) async throws(OtherFailure) -> Value?
    ) -> AsyncProvider<ID, Value, OtherFailure> {
        .init { id throws(OtherFailure) in
            if let interjected = try await interject(id) {
                interjected
            } else {
                await valueForID(id)
            }
        }
    }
}
