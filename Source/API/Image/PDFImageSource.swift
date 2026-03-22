//
//  PDFImageSource.swift
//  TPPDF
//
//  Copyright © 2016-2025 techprimate GmbH. All rights reserved.
//

import CoreGraphics
import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    import UIKit
#else
    import AppKit
#endif

/// Describes where a ``PDFImage`` obtains its pixel data.
///
/// - `image`: The ``Image`` (UIImage / NSImage) is held in memory at init time.
///   This is the original behaviour and is fully backwards-compatible.
/// - `fileURL`: The image file at the given URL is loaded on demand, immediately
///   before drawing.  An optional `size` hint may be supplied; if it is `nil`,
///   the actual pixel dimensions are read from the file metadata via
///   ``CGImageSourceCreateWithURL(_:_:)`` without decoding the full image.
public enum PDFImageSource {
    /// An already-loaded ``Image`` instance.
    case image(Image)

    /// A file-system URL whose image data will be decoded lazily.
    ///
    /// - Parameters:
    ///   - url:  Location of the image file (must be a file URL).
    ///   - size: Optional layout size hint in points.  When `nil`, TPPDF reads
    ///           the pixel dimensions from the file's metadata and uses those as
    ///           the layout size (no full decode required at init time).
    case fileURL(URL, size: CGSize?)
}

extension PDFImageSource {
    /// Returns the pixel dimensions of the image source without fully decoding
    /// the image data.
    ///
    /// For the `.image` case this is simply `image.size`.
    /// For the `.fileURL` case with an explicit `size` hint, the hint is returned
    /// directly.  Otherwise ``CGImageSourceCreateWithURL`` is used to read the
    /// `PixelWidth` / `PixelHeight` properties from the file's metadata dictionary.
    ///
    /// - Returns: The logical size in points, or `.zero` if the size could not be
    ///   determined.
    func resolveSize() -> CGSize {
        switch self {
        case .image(let img):
            return img.size
        case .fileURL(let url, let hint):
            if let hint = hint {
                return hint
            }
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                  let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
                  let pixelW = props[kCGImagePropertyPixelWidth] as? CGFloat,
                  let pixelH = props[kCGImagePropertyPixelHeight] as? CGFloat
            else {
                return .zero
            }
            return CGSize(width: pixelW, height: pixelH)
        }
    }

    /// Decodes and returns the ``Image`` represented by this source.
    ///
    /// For `.image` the stored value is returned immediately.
    /// For `.fileURL` the file is loaded with ``Image(contentsOfFile:)``.
    /// Returns `nil` if loading fails (e.g. URL unreachable).
    func resolveImage() -> Image? {
        switch self {
        case .image(let img):
            return img
        case .fileURL(let url, _):
            return Image(contentsOfFile: url.path)
        }
    }
}
