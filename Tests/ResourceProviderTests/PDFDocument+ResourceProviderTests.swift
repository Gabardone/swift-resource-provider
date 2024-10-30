//
//  PDFDocument+ResourceProviderTests.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/24/24.
//

import PDFKit

extension PDFDocument {
    static let sampleDocumentData: Data = {
        let sampleDocumentURL = Bundle.module.url(forResource: "SampleDocument", withExtension: "pdf")!
        return try! Data(contentsOf: sampleDocumentURL)
    }()
}
