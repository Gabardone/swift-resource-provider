//
//  ProviderChainTests.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

import ResourceProvider
import System
import XCTest

final class AsyncProviderTests: XCTestCase {
    /**
     We're using a mock of a three-level caching provider (in-memory cache/local file cache/network fetch).
     */
    private static func makeImageProvider(
        preloadedWeakObjectCache: WeakObjectCache<URL, CGImage>? = nil,
        source: @escaping @Sendable (URL) async throws -> Data = { _ in
            XCTFail("Unexpected call to network source.")
            return CGImage.badImageData
        },
        localFileCacheFetch: @escaping @Sendable (FilePath) -> Data? = { _ in
            XCTFail("Unexpected call to local cache fetch.")
            return nil
        },
        localFileCacheStore: @escaping @Sendable (Data, FilePath) -> Void = { _, _ in
            XCTFail("Unexpected call to local cache store.")
        },
        inMemoryCacheFetchValidation: @escaping @Sendable (CGImage?, URL) -> Void = { _, _ in
            XCTFail("Unexpected call to in memory cache fetch.")
        },
        inMemoryCacheStoreValidation: @escaping @Sendable (CGImage, URL) -> Void = { _, _ in
            XCTFail("Unexpected call to local cache store.")
        }
    ) -> some AsyncProvider<URL, CGImage, any Error> {
        Provider.source(source)
            .mapValue { data, _ in
                // We convert to image early so we validate that the data is good. We wouldn't want to store bad data.
                let image = try CGImage.makePNGImage(from: data)
                return (data, image)
            }
            .cache(AnySendableSyncCache(valueForID: localFileCacheFetch, storeValueForID: localFileCacheStore)
                .mapID { url in
                    // You're usually going to need a `mapID` to use a `LocalFileDataCache`
                    FilePath(url.lastPathComponent)
                }
                .mapValue { data, _ in
                    // We're only carrying the image for validation.
                    data
                } fromStorage: { data, _ in
                    // It's ok to convert again since if we're here it means we don't have it in memory.
                    (try? CGImage.makePNGImage(from: data)).map { (data, $0) }
                }
                .forceSendable()
                .concurrent()
            )
            .mapValue { dataAndImage, _ in
                // We no longer need the data after this.
                let (_, image) = dataAndImage
                return image
            }
            .cache((preloadedWeakObjectCache ?? WeakObjectCache())
                .makeAsync()
                .storeValueForSideEffect(sideEffect: inMemoryCacheStoreValidation)
                .valueForSideEffect(sideEffect: inMemoryCacheFetchValidation)
            )
            .coordinated() // Always finish an `async` cache chain with this one. You usually need only one at the end.
    }

    // If the data is already in-memory, immediately returns it.
    func testInMemoryImageHappyPath() async throws {
        let inMemoryCache = WeakObjectCache<URL, CGImage>()
        inMemoryCache.store(value: CGImage.sampleImage, for: .dummy)
        let inMemoryFetchExpectation = expectation(description: "In-memory cache fetch was called as expected.")

        let imageProvider = Self.makeImageProvider(
            preloadedWeakObjectCache: inMemoryCache,
            inMemoryCacheFetchValidation: { value, id in
                inMemoryFetchExpectation.fulfill()
                XCTAssertEqual(id, .dummy)
                XCTAssertEqual(value, CGImage.sampleImage)
            }
        )

        let image = try await imageProvider.value(for: .dummy)

        await fulfillment(of: [inMemoryFetchExpectation])

        XCTAssertEqual(image, CGImage.sampleImage)
    }

    // If the data is found locally, we return it and don't do anything else weird.
    func testLocallyStoredImageDataHappyPath() async throws {
        let localFileCacheFetchExpectation = expectation(description: "Local cache fetch was called as expected.")
        let inMemoryFetchExpectation = expectation(description: "In-memory cache fetch was called as expected.")
        let inMemoryStoreExpectation = expectation(description: "In-memory cache store was called as expected.")

        let imageProvider = Self.makeImageProvider(localFileCacheFetch: { filePath in
            localFileCacheFetchExpectation.fulfill()
            XCTAssertEqual(filePath, .init(URL.dummy.lastPathComponent))
            return CGImage.sampleImageData
        }, inMemoryCacheFetchValidation: { value, id in
            inMemoryFetchExpectation.fulfill()
            XCTAssertEqual(id, .dummy)
            XCTAssertEqual(value, nil)
        }, inMemoryCacheStoreValidation: { value, id in
            inMemoryStoreExpectation.fulfill()
            XCTAssertEqual(id, .dummy)
            XCTAssertEqual(value.width, CGImage.sampleImage.width)
            XCTAssertEqual(value.height, CGImage.sampleImage.height)
        })

        let image = try await imageProvider.value(for: .dummy)

        await fulfillment(of: [localFileCacheFetchExpectation, inMemoryFetchExpectation, inMemoryStoreExpectation])

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image.width, CGImage.sampleImage.width)
        XCTAssertEqual(image.height, CGImage.sampleImage.height)
    }

    // If the data is not local, we get remote and store.
    func testRemotelyStoredImageDataHappyPath() async throws {
        let networkSourceExpectation = expectation(description: "Network source was called as expected.")
        let localFileCacheFetchExpectation = expectation(description: "Local cache fetch was called as expected.")
        let localFileCacheStoreExpectation = expectation(description: "Local cache store was called as expected.")
        let inMemoryFetchExpectation = expectation(description: "In-memory cache fetch was called as expected.")
        let inMemoryStoreExpectation = expectation(description: "In-memory cache store was called as expected.")

        let imageProvider = Self.makeImageProvider { url in
            networkSourceExpectation.fulfill()
            XCTAssertEqual(url, .dummy)
            return CGImage.sampleImageData
        } localFileCacheFetch: { filePath in
            localFileCacheFetchExpectation.fulfill()
            XCTAssertEqual(filePath, .init(URL.dummy.lastPathComponent))
            return nil
        } localFileCacheStore: { data, filePath in
            localFileCacheStoreExpectation.fulfill()
            XCTAssertEqual(data, CGImage.sampleImageData)
            XCTAssertEqual(filePath, .init(URL.dummy.lastPathComponent))
        } inMemoryCacheFetchValidation: { image, url in
            inMemoryFetchExpectation.fulfill()
            XCTAssertEqual(url, .dummy)
            XCTAssertNil(image)
        } inMemoryCacheStoreValidation: { image, url in
            inMemoryStoreExpectation.fulfill()
            XCTAssertEqual(url, .dummy)
            XCTAssertEqual(image.width, CGImage.sampleImage.width)
            XCTAssertEqual(image.height, CGImage.sampleImage.height)
        }

        let image = try await imageProvider.value(for: .dummy)

        await fulfillment(
            of: [
                networkSourceExpectation,
                localFileCacheFetchExpectation,
                localFileCacheStoreExpectation,
                inMemoryFetchExpectation,
                inMemoryStoreExpectation
            ]
        )

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image.width, CGImage.sampleImage.width)
        XCTAssertEqual(image.height, CGImage.sampleImage.height)
    }

    // If the remote data is bad we throw.
    func testRemoteDataIsBad() async throws {
        let networkSourceExpectation = expectation(description: "Network source was called as expected.")
        let localFileCacheFetchExpectation = expectation(description: "Local cache fetch was called as expected.")
        let inMemoryFetchExpectation = expectation(description: "In-memory cache fetch was called as expected.")

        let imageProvider = Self.makeImageProvider { url in
            networkSourceExpectation.fulfill()
            XCTAssertEqual(url, .dummy)
            return CGImage.badImageData
        } localFileCacheFetch: { filePath in
            localFileCacheFetchExpectation.fulfill()
            XCTAssertEqual(filePath, .init(URL.dummy.lastPathComponent))
            return nil
        } inMemoryCacheFetchValidation: { image, url in
            inMemoryFetchExpectation.fulfill()
            XCTAssertEqual(url, .dummy)
            XCTAssertNil(image)
        }

        do {
            _ = try await imageProvider.value(for: .dummy)
            XCTFail("Exception expected, didn't happen.")
        } catch CGImage.ImageTestError.dataIsNotValidPNG {
            // This block intentionally left blank. This is the error we expect.
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        await fulfillment(of: [networkSourceExpectation, localFileCacheFetchExpectation, inMemoryFetchExpectation])
    }

    // Tests that retrying works if source is good the second time (no crap left behind on error).
    // swiftlint:disable:next function_body_length
    func testRemoteDataIsBadButRetryWorks() async throws {
        let networkSourceExpectation = expectation(description: "Network source was called as expected.")
        networkSourceExpectation.expectedFulfillmentCount = 2
        let localFileCacheFetchExpectation = expectation(description: "Local cache fetch was called as expected.")
        localFileCacheFetchExpectation.expectedFulfillmentCount = 2
        let localFileCacheStoreExpectation = expectation(description: "Local cache store was called as expected.")
        let inMemoryFetchExpectation = expectation(description: "In-memory cache fetch was called as expected.")
        inMemoryFetchExpectation.expectedFulfillmentCount = 2
        let inMemoryStoreExpectation = expectation(description: "In-memory cache store was called as expected.")

        actor PassCheck {
            var gotPassed: Bool = false

            func pass() {
                gotPassed = true
            }
        }

        let firstPass = PassCheck()
        let imageProvider = Self.makeImageProvider { url in
            networkSourceExpectation.fulfill()
            XCTAssertEqual(url, .dummy)
            if await firstPass.gotPassed {
                return CGImage.sampleImageData
            } else {
                await firstPass.pass()
                return CGImage.badImageData
            }
        } localFileCacheFetch: { filePath in
            localFileCacheFetchExpectation.fulfill()
            XCTAssertEqual(filePath, .init(URL.dummy.lastPathComponent))
            return nil
        } localFileCacheStore: { data, filePath in
            localFileCacheStoreExpectation.fulfill()
            XCTAssertEqual(data, CGImage.sampleImageData)
            XCTAssertEqual(filePath, .init(URL.dummy.lastPathComponent))
        } inMemoryCacheFetchValidation: { image, url in
            inMemoryFetchExpectation.fulfill()
            XCTAssertEqual(url, .dummy)
            XCTAssertNil(image)
        } inMemoryCacheStoreValidation: { image, url in
            inMemoryStoreExpectation.fulfill()
            XCTAssertEqual(url, .dummy)
            XCTAssertEqual(image.width, CGImage.sampleImage.width)
            XCTAssertEqual(image.height, CGImage.sampleImage.height)
        }

        do {
            _ = try await imageProvider.value(for: .dummy)
            XCTFail("Exception expected, didn't happen.")
        } catch CGImage.ImageTestError.dataIsNotValidPNG {
            // This block intentionally left blank. This is the error we expect.
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        // Try again, this one should work.
        let image = try await imageProvider.value(for: .dummy)

        await fulfillment(
            of: [
                networkSourceExpectation,
                localFileCacheFetchExpectation,
                localFileCacheStoreExpectation,
                inMemoryFetchExpectation,
                inMemoryStoreExpectation
            ]
        )

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image.width, CGImage.sampleImage.width)
        XCTAssertEqual(image.height, CGImage.sampleImage.height)
    }
}
