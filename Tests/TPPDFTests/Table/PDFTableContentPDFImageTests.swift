//
//  PDFTableContentPDFImageTests.swift
//  TPPDF
//
//  Copyright © 2016-2026 techprimate GmbH. All rights reserved.
//

import Foundation
import Testing
@testable import TPPDF

struct PDFTableContentPDFImageTests {
    @Test func settingPDFImageUpdatesTypeAndValue() throws {
        let content = try #require(try PDFTableContent(content: nil))
        let value = PDFImage(image: Image())

        try content.setContent(content: value)

        #expect(content.type == .pdfImage)
        #expect(content.pdfImageValue === value)
    }

    @Test func pdfImagePredicateAndValueMatchOnlyPDFImageType() {
        let value = PDFImage(image: Image())
        let content = PDFTableContent(type: .pdfImage, content: value)

        #expect(content.isPDFImage)
        #expect(content.pdfImageValue === value)

        content.type = .image
        #expect(!content.isPDFImage)
        #expect(content.pdfImageValue == nil)

        content.type = .none
        #expect(!content.isPDFImage)
    }

    @Test func pdfImageExtensionProducesPDFImageContent() {
        let pdfImage = PDFImage(image: Image())

        let content = pdfImage.asTableContent

        #expect(content.type == .pdfImage)
        #expect(content.content as? PDFImage === pdfImage)
    }
}
