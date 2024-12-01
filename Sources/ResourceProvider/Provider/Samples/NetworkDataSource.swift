//
//  NetworkDataSource.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

public extension Provider {
    /**
     A simple implementation of a network based ``AsyncProvider`` source that returns the data at the given `URL`.

     This is a most basic example, if you need more sophisticated networking you can build up using this one as a
     baseline. It returns an ``AsyncProvider`` since networking is slow enough that it wouldn't make sense to make it
     synchronous for about any use case. Besides the API we use in the implementation is already `async`.

     Some suggestions for use:
     - Use ``mapID(_:)`` to convert any other unique id to a `URL` that can feed this. Could even put in all the logic
     to go from an agreed upon identifying `struct` to a REST URL.
     - Make sure there's a ``coordinated()`` addition to the provider chain if you don't want the same `URL` to go to
     the network twice.
     - Parameter urlSession: The `URLSession` to use for the downloads. Defaults to `URLSession.default`
     - Returns: An ``AsyncProvider`` that fetches `Data` from the given `URL`s from the network.
     */
    static func networkDataSource(urlSession: URLSession = .shared) -> some AsyncProvider<URL, Data, any Error> {
        source { url in
            try await urlSession.data(from: url).0
        }
    }
}
