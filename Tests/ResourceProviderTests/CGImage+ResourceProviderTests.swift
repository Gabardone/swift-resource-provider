//
//  CGImage+ResourceProviderTests.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/24/24.
//

import CoreGraphics
import ImageIO
import Foundation

extension CGImage {
    // Does not `throw` as it's expected for the test setup to work.
    static let sampleImageURL = Bundle.module.url(forResource: "SampleImage", withExtension: "jpeg")!

    // Does not `throw` as it's expected for the test setup to work.
    static let sampleImageData: Data = try! Data(contentsOf: sampleImageURL)

    // This shouldn't parse into any CGImage
    static let badImageData = Data(count: 16)

    // Does not `throw` as it's expected for the test setup to work.
    static let sampleImage: CGImage = {
        let dataProvider = CGDataProvider(url: sampleImageURL as CFURL)!
        return CGImage(
            jpegDataProviderSource: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!
    }()

    enum ImageTestError: Error {
        case unableToCreateProviderFromData
        case dataIsNotValidPNG
    }

    static func makePNGImage(from pngData: Data) throws(ImageTestError) -> CGImage {
        guard let dataProvider = CGDataProvider(data: pngData as CFData) else {
            throw ImageTestError.unableToCreateProviderFromData
        }

        guard let image = CGImage(
            jpegDataProviderSource: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            throw ImageTestError.dataIsNotValidPNG
        }

        return image
    }
}
