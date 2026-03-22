//
//  PDFImage+PDFTableContent.swift
//  TPPDF
//
//  Copyright © 2016-2025 techprimate GmbH. All rights reserved.
//

// MARK: - PDFImage + PDFTableContentable

extension PDFImage: PDFTableContentable {
    /// Wraps this ``PDFImage`` in a ``PDFTableContent`` with type ``PDFTableContent/ContentType/pdfImage``.
    public var asTableContent: PDFTableContent {
        PDFTableContent(type: .pdfImage, content: self)
    }
}
