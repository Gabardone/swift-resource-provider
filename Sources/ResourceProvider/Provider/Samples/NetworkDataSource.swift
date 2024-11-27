//
//  NetworkDataSource.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

public extension Provider {
    /**
     A simple implementation of a network based provider source that returns the data at the given `URL`.

     This is a most basic example, if you need more sophisticated networking you can build up using this one as a
     baseline. It returns a `ThrowingAsyncResourceProvider` since networking is slow enough that it wouldn't make sense
     to make it synchronous for about any use case.

     Some suggestions for use:
     - Use `mapID(_:)` to convert any other unique id to a `URL` that can feed this. Could even put in all the logic
     to go from an agreed upon UID to a REST URL.
     - Make sure there's a `coordinated()` addition to the provider chain if you don't want the same `URL` to go to the
     network twice.
     */
    static func networkDataSource(urlSession: URLSession = .shared) -> some AsyncProvider<URL, Data, any Error> {
        source { url in
            try await urlSession.data(from: url).0
        }
    }
}
