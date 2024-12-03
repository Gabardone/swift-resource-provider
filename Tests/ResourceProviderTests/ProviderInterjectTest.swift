//
//  ProviderInterjectTest.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 11/26/24.
//

import ResourceProvider
import Testing

// swiftlint:disable function_body_length

struct ProviderInterjectTest {
    @Test func interjectedNonThrowingFizzBuzz() {
        let provider: some SyncProvider<Int, String, Never> = Provider.source { (id: Int) in
            // Just return the id as the value.
            "\(id)"
        }.interject { id in
            (id % 3 == 0) ? "fizz" : nil
        }.interject { id in
            (id % 5 == 0) ? "buzz" : nil
        }.interject { id in
            (id % 3 == 0 && id % 5 == 0) ? "fizzbuzz" : nil
        }

        let fifteenResults = (1 ... 15).map { id in
            provider.value(for: id)
        }

        let expectedResults = [
            "1", "2", "fizz", "4", "buzz", "fizz", "7", "8", "fizz", "buzz", "11", "fizz", "13", "14", "fizzbuzz"
        ]

        #expect(fifteenResults == expectedResults)
    }

    @Test func inerjectedSameErrorThrowingFizzBuzz() {
        enum FizzBuzzError: Error {
            case fizz
            case buzz
            case fizzBuzz
        }

        let provider: some SyncProvider<Int, Int, FizzBuzzError> = Provider.source { (id: Int) in
            // Just return the id as the value.
            id
        }.interject { id throws(FizzBuzzError) in
            if id % 3 == 0 {
                throw .fizz
            } else {
                nil
            }
        }.interject { id throws(FizzBuzzError) in
            if id % 5 == 0 {
                throw .buzz
            } else {
                nil
            }
        }.interject { id throws(FizzBuzzError) in
            if id % 3 == 0, id % 5 == 0 {
                throw .fizzBuzz
            } else {
                nil
            }
        }

        let fifteenResults = (1 ... 15).map { id -> Result<Int, FizzBuzzError> in
            do throws(FizzBuzzError) {
                return try .success(provider.value(for: id))
            } catch {
                return .failure(error)
            }
        }

        let expectedResults: [Result<Int, FizzBuzzError>] = [
            .success(1),
            .success(2),
            .failure(.fizz),
            .success(4),
            .failure(.buzz),
            .failure(.fizz),
            .success(7),
            .success(8),
            .failure(.fizz),
            .failure(.buzz),
            .success(11),
            .failure(.fizz),
            .success(13),
            .success(14),
            .failure(.fizzBuzz)
        ]

        #expect(fifteenResults == expectedResults)
    }

    @Test func inerjectedDifferentErrorThrowingFizzBuzz() {
        struct Fizz: Error {}
        struct Buzz: Error {}
        struct FizzBuzz: Error {}

        let provider: some SyncProvider<Int, Int, any Error> = Provider.source { (id: Int) in
            // Just return the id as the value.
            id
        }.interject { id throws(Fizz) in
            if id % 3 == 0 {
                throw .init()
            } else {
                nil
            }
        }.interject { id throws(Buzz) in
            if id % 5 == 0 {
                throw .init()
            } else {
                nil
            }
        }.interject { id throws(FizzBuzz) in
            if id % 3 == 0, id % 5 == 0 {
                throw .init()
            } else {
                nil
            }
        }

        let fifteenResults = (1 ... 15).map { id -> Result<Int, any Error> in
            do {
                return try .success(provider.value(for: id))
            } catch {
                return .failure(error)
            }
        }

        let expectedResults: [Result<Int, any Error>] = [
            .success(1),
            .success(2),
            .failure(Fizz()),
            .success(4),
            .failure(Buzz()),
            .failure(Fizz()),
            .success(7),
            .success(8),
            .failure(Fizz()),
            .failure(Buzz()),
            .success(11),
            .failure(Fizz()),
            .success(13),
            .success(14),
            .failure(FizzBuzz())
        ]

        #expect(!zip(fifteenResults, expectedResults).contains { result, expected in
            switch (result, expected) {
            case let (.success(value), .success(expectedValue)):
                value != expectedValue

            case let (.failure(error), .failure(expectedError)):
                type(of: error) != type(of: expectedError)

            default:
                true
            }
        })
    }
}

// swiftlint:enable function_body_length
