//
//  PDFImageSource_Spec.swift
//  TPPDF
//
//  Copyright © 2016-2025 techprimate GmbH. All rights reserved.
//

import CoreGraphics
import Foundation
import Nimble
import Quick
@testable import TPPDF

class PDFImageSource_Spec: QuickSpec {
    override func spec() {
        // swiftlint:disable:next line_length
        let base64String = Data("/9j/4AAQSkZJRgABAQAASABIAAD/4QBYRXhpZgAATU0AKgAAAAgAAgESAAMAAAABAAEAAIdpAAQAAAABAAAAJgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAAaADAAQAAAABAAAAAQAAAAD/7QA4UGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAAAA4QklNBCUAAAAAABDUHYzZjwCyBOmACZjs+EJ+/8AAEQgAAQABAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/bAEMABgYGBgYGCgYGCg4KCgoOEg4ODg4SFxISEhISFxwXFxcXFxccHBwcHBwcHCIiIiIiIicnJycnLCwsLCwsLCwsLP/bAEMBBwcHCwoLEwoKEy4fGh8uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLv/dAAQAAf/aAAwDAQACEQMRAD8A6+iiivxY/Sz/2Q==".utf8)
        let imageData = Data(base64Encoded: base64String)!
        let testImage = Image(data: imageData)!

        var tempURL: URL!

        beforeEach {
            let dir = FileManager.default.temporaryDirectory
            tempURL = dir.appendingPathComponent("PDFImageSource_Spec_\(UUID().uuidString).jpg")
            try? imageData.write(to: tempURL)
        }

        afterEach {
            try? FileManager.default.removeItem(at: tempURL)
        }

        describe("PDFImageSource") {
            context(".image case") {
                it("resolveSize() returns image.size") {
                    let source = PDFImageSource.image(testImage)
                    expect(source.resolveSize()) == testImage.size
                }

                it("resolveImage() returns the stored image") {
                    let source = PDFImageSource.image(testImage)
                    expect(source.resolveImage()) == testImage
                }
            }

            context(".fileURL case with explicit size hint") {
                it("resolveSize() returns the hint") {
                    let hint = CGSize(width: 200, height: 100)
                    let source = PDFImageSource.fileURL(tempURL, size: hint)
                    expect(source.resolveSize()) == hint
                }

                it("resolveImage() loads the file") {
                    let source = PDFImageSource.fileURL(tempURL, size: CGSize(width: 1, height: 1))
                    expect(source.resolveImage()).toNot(beNil())
                }
            }

            context(".fileURL case without size hint") {
                it("resolveSize() reads pixel dimensions from metadata") {
                    let source = PDFImageSource.fileURL(tempURL, size: nil)
                    let size = source.resolveSize()
                    expect(size.width) > 0
                    expect(size.height) > 0
                }

                it("resolveSize() returns .zero for non-existent file") {
                    let missing = FileManager.default.temporaryDirectory.appendingPathComponent("does_not_exist.jpg")
                    let source = PDFImageSource.fileURL(missing, size: nil)
                    expect(source.resolveSize()) == CGSize.zero
                }

                it("resolveImage() returns nil for non-existent file") {
                    let missing = FileManager.default.temporaryDirectory.appendingPathComponent("does_not_exist.jpg")
                    let source = PDFImageSource.fileURL(missing, size: nil)
                    expect(source.resolveImage()).to(beNil())
                }
            }
        }
    }
}
