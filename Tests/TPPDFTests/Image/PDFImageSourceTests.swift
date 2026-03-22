//
//  PDFImageSourceTests.swift
//  TPPDF
//
//  Copyright © 2016-2026 techprimate GmbH. All rights reserved.
//

import CoreGraphics
import Foundation
import Testing
@testable import TPPDF

struct PDFImageSourceTests {
    // MARK: - Helpers

    private func fixtureURL() throws -> URL {
        try #require(Bundle.module.url(forResource: "image-fixture", withExtension: "jpg"))
    }

    private func fixtureImage() throws -> Image {
        try #require(Image(data: Data(contentsOf: fixtureURL())))
    }

    private var missingURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("does_not_exist_\(UUID().uuidString).jpg")
    }

    // MARK: - .image

    @Test func imageSourceResolvesStoredImageAndSize() throws {
        let image = try fixtureImage()
        let source = PDFImageSource.image(image)

        #expect(source.resolveSize() == image.size)
        #expect(source.resolveImage() == image)
    }

    // MARK: - .fileURL

    @Test func fileURLSourceWithHintReturnsHint() throws {
        let hint = CGSize(width: 200, height: 100)
        let source = try PDFImageSource.fileURL(fixtureURL(), size: hint)

        #expect(source.resolveSize() == hint)
    }

    @Test func fileURLSourceLoadsImageFromDisk() throws {
        let source = try PDFImageSource.fileURL(fixtureURL(), size: CGSize(width: 1, height: 1))

        #expect(source.resolveImage() != nil)
    }

    @Test func fileURLSourceWithoutHintReadsPixelDimensions() throws {
        let size = try PDFImageSource.fileURL(fixtureURL(), size: nil).resolveSize()

        #expect(size.width > 0)
        #expect(size.height > 0)
    }

    @Test func fileURLSourceForMissingFileResolvesToZeroAndNil() {
        let source = PDFImageSource.fileURL(missingURL, size: nil)

        #expect(source.resolveSize() == .zero)
        #expect(source.resolveImage() == nil)
    }

    // MARK: - .block

    @Test func blockSourceReturnsResolverResult() throws {
        let image = try fixtureImage()

        #expect(PDFImageSource.block(id: UUID(), size: nil, resolver: { image }).resolveImage() == image)
        #expect(PDFImageSource.block(id: UUID(), size: nil, resolver: { nil }).resolveImage() == nil)
    }

    @Test func blockSourceSizeHintSkipsResolver() throws {
        let image = try fixtureImage()
        let hint = CGSize(width: 42, height: 24)
        var resolverCalled = false
        let source = PDFImageSource.block(id: UUID(), size: hint) {
            resolverCalled = true
            return image
        }

        #expect(source.resolveSize() == hint)
        #expect(!resolverCalled)
    }

    @Test func blockSourceWithoutHintUsesResolvedImageSize() throws {
        let image = try fixtureImage()

        #expect(PDFImageSource.block(id: UUID(), size: nil, resolver: { image }).resolveSize() == image.size)
        #expect(PDFImageSource.block(id: UUID(), size: nil, resolver: { nil }).resolveSize() == .zero)
    }

    @Test func blockSourcesCompareByIdentifier() throws {
        let image = try fixtureImage()
        let id = UUID()

        let sameA = PDFImage(source: .block(id: id, size: nil, resolver: { image }))
        let sameB = PDFImage(source: .block(id: id, size: nil, resolver: { image }))
        let otherA = PDFImage(source: .block(id: UUID(), size: nil, resolver: { image }))
        let otherB = PDFImage(source: .block(id: UUID(), size: nil, resolver: { image }))

        #expect(sameA == sameB)
        #expect(otherA != otherB)
    }

    @Test func blockConvenienceInitGeneratesUniqueIdentifiers() throws {
        let image = try fixtureImage()

        #expect(PDFImage(block: { image }) != PDFImage(block: { image }))
    }

    @Test func copyPreservesBlockIdentifier() throws {
        let image = try fixtureImage()
        let original = PDFImage(block: { image })

        #expect(original == original.copy)
    }

    // MARK: - PDFImage with sources

    @Test func pdfImageWithFileURLSourceUsesExplicitSize() throws {
        let size = CGSize(width: 50, height: 50)

        #expect(try PDFImage(source: .fileURL(fixtureURL(), size: size)).size == size)
    }

    @Test func pdfImageWithMissingFileResolvesToNil() {
        let pdfImage = PDFImage(source: .fileURL(missingURL, size: CGSize(width: 10, height: 10)))

        #expect(pdfImage.resolveImage() == nil)
    }

    @Test func settingImageReplacesSource() throws {
        let image = try fixtureImage()
        let pdfImage = try PDFImage(source: .fileURL(fixtureURL(), size: CGSize(width: 1, height: 1)))

        pdfImage.image = image

        #expect(pdfImage.resolveImage() == image)
    }

    @Test func fileURLImagesCompareByURL() throws {
        let image = try fixtureImage()
        let size = CGSize(width: 100, height: 100)
        let url1 = URL(fileURLWithPath: "/tmp/image1.jpg")
        let url2 = URL(fileURLWithPath: "/tmp/image2.jpg")
        func make(_ source: PDFImageSource) -> PDFImage {
            PDFImage(source: source, caption: PDFSimpleText(text: "EXAMPLE"), size: size, sizeFit: .height, quality: 0.9)
        }

        #expect(make(.fileURL(url1, size: size)) == make(.fileURL(url1, size: size)))
        #expect(make(.fileURL(url1, size: size)) != make(.fileURL(url2, size: size)))
        #expect(make(.image(image)) != make(.fileURL(url1, size: size)))
    }
}
