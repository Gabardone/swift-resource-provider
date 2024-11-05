//
//  PDFDocument+ResourceProviderTests.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/24/24.
//

import PDFKit

extension PDFDocument {
    // This shouldn't parse into any PDFDocument
    static let badDocumentData = Data(count: 16)

    static let sampleDocumentData: Data = {
        let sampleDocumentURL = Bundle.module.url(forResource: "SampleDocument", withExtension: "pdf")!
        return try! Data(contentsOf: sampleDocumentURL) // swiftlint:disable:this force_try
    }()
}
