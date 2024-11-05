//
//  SyncProviderTest.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/30/24.
//

import PDFKit
import ResourceProvider
import System
import Testing

/// Tests sync providers with management of a non-Sendable type to ensure the API works.
struct SyncProviderTest {
    private enum ProviderError: Error {
        case cannotBuildPDFFromData
    }

    private class UncheckedFulfillment: @unchecked Sendable {
        var fulfillments: Int = 0

        func fulfill() { fulfillments += 1 }
    }

    private static func makeDocumentProvider(
        preloadedWeakObjectCache: WeakObjectCache<URL, PDFDocument>? = nil,
        source: @escaping (URL) throws -> Data = { _ in
            Issue.record("Unexpected call to network source.")
            return PDFDocument.badDocumentData
        },
        localFileCacheFetch: @escaping @Sendable (FilePath) -> Data? = { _ in
            Issue.record("Unexpected call to local cache fetch.")
            return nil
        },
        localFileCacheStore: @escaping @Sendable (Data, FilePath) -> Void = { _, _ in
            Issue.record("Unexpected call to local cache store.")
        },
        inMemoryCacheFetchValidation: @escaping (PDFDocument?, URL) -> Void = { _, _ in
            Issue.record("Unexpected call to in memory cache fetch.")
        },
        inMemoryCacheStoreValidation: @escaping (PDFDocument, URL) -> Void = { _, _ in
            Issue.record("Unexpected call to local cache store.")
        }
    ) -> some SyncProvider<URL, PDFDocument, any Error> {
        Provider.source(source)
            .mapValue { data, _ in
                // We convert to pdf document early to validate that the data is good. We wouldn't want to store bad
                // data.
                guard let pdfDocument = PDFDocument(data: data) else {
                    throw ProviderError.cannotBuildPDFFromData
                }

                return (data, pdfDocument)
            }
            .cache(AnySendableSyncCache(valueForID: localFileCacheFetch, storeValueForID: localFileCacheStore)
                .mapID { url in
                    // You're usually going to need a `mapID` to use a `LocalFileDataCache`
                    FilePath(url.lastPathComponent)
                }
                .mapValueToStorage { data, _ in
                    // We're only carrying the image for validation.
                    data
                } fromStorage: { data, _ in
                    // It's ok to convert again since if we're here it means we don't have it in memory.

                    PDFDocument(data: data).map { (data, $0) }
                }
            )
            .mapValue { dataAndPDFDocument, _ in
                // We no longer need the data after this.
                let (_, pdfDocument) = dataAndPDFDocument
                return pdfDocument
            }
            .cache((preloadedWeakObjectCache ?? WeakObjectCache())
                .storeValueForSideEffect(sideEffect: inMemoryCacheStoreValidation)
                .valueForSideEffect(sideEffect: inMemoryCacheFetchValidation)
            )
    }

    @Test func inMemoryDocumentHappyPath() throws {
        let expectedDocument = PDFDocument(data: PDFDocument.sampleDocumentData)!
        let inMemoryCache = WeakObjectCache<URL, PDFDocument>()
        inMemoryCache.store(value: expectedDocument, for: .dummy)
        var memoryFetchHappened = false

        let documentProvider = Self.makeDocumentProvider(
            preloadedWeakObjectCache: inMemoryCache,
            inMemoryCacheFetchValidation: { value, id in
                #expect(!memoryFetchHappened)
                memoryFetchHappened = true
                #expect(id == .dummy)
                #expect(value == expectedDocument)
            }
        )

        let pdfDocument = try documentProvider.value(for: URL.dummy)

        #expect(memoryFetchHappened)
        #expect(pdfDocument == expectedDocument)
    }

    @Test func locallyStoredDocumentHappyPath() throws {
        let localFileFetchHappened = UncheckedFulfillment()
        var inMemoryFetchHappened = false
        var inMemoryStoreHappened = false
        let expectedDocumentData = PDFDocument(data: PDFDocument.sampleDocumentData)?.dataRepresentation()

        let documentProvider = Self.makeDocumentProvider(localFileCacheFetch: { filePath in
            #expect(localFileFetchHappened.fulfillments == 0)
            localFileFetchHappened.fulfill()
            #expect(filePath == .init(URL.dummy.lastPathComponent))
            return PDFDocument.sampleDocumentData
        }, inMemoryCacheFetchValidation: { value, id in
            #expect(!inMemoryFetchHappened)
            inMemoryFetchHappened = true
            #expect(id == .dummy)
            #expect(value == nil)
        }, inMemoryCacheStoreValidation: { value, id in
            #expect(!inMemoryStoreHappened)
            inMemoryStoreHappened = true
            #expect(id == .dummy)
            #expect(value.dataRepresentation()?.count == expectedDocumentData?.count)
        })

        let pdfDocument = try documentProvider.value(for: .dummy)

        #expect((localFileFetchHappened.fulfillments == 1) && inMemoryFetchHappened && inMemoryStoreHappened)
        #expect(pdfDocument.dataRepresentation()?.count == expectedDocumentData?.count)
    }

    @Test func remotelyStoredImageDataHappyPath() throws {
        var networkSourceHappened = false
        let localFileCacheFetchHappened = UncheckedFulfillment()
        let localFileCacheStoreHappened = UncheckedFulfillment()
        var inMemoryFetchHappened = false
        var inMemoryStoreHappened = false
        let expectedDocumentData = PDFDocument(data: PDFDocument.sampleDocumentData)?.dataRepresentation()

        let documentProvider = Self.makeDocumentProvider { url in
            #expect(!networkSourceHappened)
            networkSourceHappened = true
            #expect(url == .dummy)
            return PDFDocument.sampleDocumentData
        } localFileCacheFetch: { filePath in
            #expect(localFileCacheFetchHappened.fulfillments == 0)
            localFileCacheFetchHappened.fulfill()
            #expect(filePath == .init(URL.dummy.lastPathComponent))
            return nil
        } localFileCacheStore: { data, filePath in
            #expect(localFileCacheStoreHappened.fulfillments == 0)
            localFileCacheStoreHappened.fulfill()
            #expect(data == PDFDocument.sampleDocumentData)
            #expect(filePath == .init(URL.dummy.lastPathComponent))
        } inMemoryCacheFetchValidation: { image, url in
            #expect(!inMemoryFetchHappened)
            inMemoryFetchHappened = true
            #expect(url == .dummy)
            #expect(image == nil)
        } inMemoryCacheStoreValidation: { value, url in
            #expect(!inMemoryStoreHappened)
            inMemoryStoreHappened = true
            #expect(url == .dummy)
            #expect(value.dataRepresentation()?.count == expectedDocumentData?.count)
        }

        let pdfDocument = try documentProvider.value(for: .dummy)

        #expect(
            networkSourceHappened
                && (localFileCacheFetchHappened.fulfillments == 1)
                && (localFileCacheStoreHappened.fulfillments == 1)
                && inMemoryFetchHappened
                && inMemoryStoreHappened
        )
        #expect(pdfDocument.dataRepresentation()?.count == expectedDocumentData?.count)
    }

    @Test func remoteDataIsBad() throws {
        var networkSourceHappened = false
        let localFileCacheFetchHappened = UncheckedFulfillment()
        var inMemoryFetchHappened = false

        let documentProvider = Self.makeDocumentProvider { url in
            #expect(!networkSourceHappened)
            networkSourceHappened = true
            #expect(url == .dummy)
            return PDFDocument.badDocumentData
        } localFileCacheFetch: { filePath in
            #expect(localFileCacheFetchHappened.fulfillments == 0)
            localFileCacheFetchHappened.fulfill()
            #expect(filePath == .init(URL.dummy.lastPathComponent))
            return nil
        } inMemoryCacheFetchValidation: { image, url in
            #expect(!inMemoryFetchHappened)
            inMemoryFetchHappened = true
            #expect(url == .dummy)
            #expect(image == nil)
        }

        #expect(throws: ProviderError.cannotBuildPDFFromData) {
            _ = try documentProvider.value(for: .dummy)
        }
        #expect(networkSourceHappened && (localFileCacheFetchHappened.fulfillments == 1) && inMemoryFetchHappened)
    }

    @Test func remoteDataIsBadButRetryWorks() throws {
        var networkSourceHappened = 0
        let expectedNetworkSourceFulfillments = 2
        let localFileCacheFetchHappened = UncheckedFulfillment()
        let expectedLocalFileCacheFetchFulfillments = 2
        let localFileCacheStoreHappened = UncheckedFulfillment()
        var inMemoryFetchHappened = 0
        let expectedInMemoryFetchFulfillments = 2
        var inMemoryStoreHappened = false
        let expectedDocumentData = PDFDocument(data: PDFDocument.sampleDocumentData)?.dataRepresentation()

        let documentProvider = Self.makeDocumentProvider { url in
            #expect(networkSourceHappened < expectedNetworkSourceFulfillments)
            #expect(url == .dummy)
            defer { networkSourceHappened += 1 }
            if networkSourceHappened == 0 {
                return PDFDocument.badDocumentData
            } else {
                return PDFDocument.sampleDocumentData
            }
        } localFileCacheFetch: { filePath in
            #expect(localFileCacheFetchHappened.fulfillments < expectedLocalFileCacheFetchFulfillments)
            localFileCacheFetchHappened.fulfill()
            #expect(filePath == .init(URL.dummy.lastPathComponent))
            return nil
        } localFileCacheStore: { data, filePath in
            #expect(localFileCacheStoreHappened.fulfillments == 0)
            localFileCacheStoreHappened.fulfill()
            #expect(data == PDFDocument.sampleDocumentData)
            #expect(filePath == .init(URL.dummy.lastPathComponent))
        } inMemoryCacheFetchValidation: { image, url in
            #expect(inMemoryFetchHappened < expectedInMemoryFetchFulfillments)
            inMemoryFetchHappened += 1
            #expect(url == .dummy)
            #expect(image == nil)
        } inMemoryCacheStoreValidation: { value, url in
            #expect(!inMemoryStoreHappened)
            inMemoryStoreHappened = true
            #expect(url == .dummy)
            #expect(value.dataRepresentation()?.count == expectedDocumentData?.count)
        }

        #expect(throws: ProviderError.cannotBuildPDFFromData) {
            _ = try documentProvider.value(for: .dummy)
        }

        // Try again, this one should work.
        let pdfDocument = try documentProvider.value(for: .dummy)

        #expect(
            (networkSourceHappened == expectedNetworkSourceFulfillments)
                && (localFileCacheFetchHappened.fulfillments == expectedLocalFileCacheFetchFulfillments)
                && (localFileCacheStoreHappened.fulfillments == 1)
                && (inMemoryFetchHappened == expectedInMemoryFetchFulfillments)
                && inMemoryStoreHappened
        )
        #expect(pdfDocument.dataRepresentation()?.count == expectedDocumentData?.count)
    }
}
