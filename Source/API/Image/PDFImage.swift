//
//  PDFImage.swift
//  TPPDF
//
//  Created by Philip Niedertscheider on 08.11.2017.
//  Copyright © 2016-2025 techprimate GmbH. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    import UIKit
#else
    import AppKit
#endif

/**
 * Image element for the PDF document.
 *
 * Contains all information about an image, including the caption.
 */
public class PDFImage: PDFDocumentObject {

    // MARK: - Stored Properties

    /// The underlying source of the image data.
    internal var source: PDFImageSource

    // MARK: - Computed Properties (Backwards Compatibility)

    /**
     * The actual image.
     *
     * For `.image` sources this returns the stored value directly.
     * For `.fileURL` sources this decodes the file on every access.
     * Setting this property updates the backing source to `.image(newValue)`.
     */
    public var image: Image {
        get {
            source.resolveImage() ?? Image()
        }
        set {
            source = .image(newValue)
        }
    }

    /**
     * An instance of a `PDFText` subclass.
     * Use `PDFSimpleText` for a simple, container-based styled caption and `PDFAttributedText` for advanced styling.
     */
    public var caption: PDFText?

    /// The size of the image in the PDF document
    public var size: CGSize

    /// Defines how the image will fit if not enough space is given
    public var sizeFit: PDFImageSizeFit

    /**
     * JPEG quality of image.
     *
     * Value ranges between 0.0 and 1.0, maximum quality equals 1.0
     */
    public var quality: CGFloat

    /// Options used for changing the image before drawing
    public var options: PDFImageOptions

    /// Optional corner radius, is used if the `options` are set.
    public var cornerRadius: CGFloat?

    // MARK: - Initialisers

    /**
     * Creates a new `PDFImage` backed by the given `PDFImageSource`.
     *
     * This is the preferred initializer for lazy / file-based images.
     *
     * - Parameters:
     *   - source:       Source of the image data; see ``PDFImageSource``.
     *   - caption:      Optional caption, defaults to `nil`.
     *   - size:         Layout size in points.  When `.zero`, the size is
     *                   resolved from `source` without fully decoding the image.
     *   - sizeFit:      How the image scales when space is constrained.
     *   - quality:      JPEG compression quality (0.0 – 1.0).
     *   - options:      Image processing flags.
     *   - cornerRadius: Optional corner radius.
     */
    public init(
        source: PDFImageSource,
        caption: PDFText? = nil,
        size: CGSize = .zero,
        sizeFit: PDFImageSizeFit = .widthHeight,
        quality: CGFloat = 0.85,
        options: PDFImageOptions = [.resize, .compress],
        cornerRadius: CGFloat? = nil
    ) {
        self.source = source
        self.caption = caption
        self.size = (size == .zero) ? source.resolveSize() : size
        self.sizeFit = sizeFit
        self.quality = quality
        self.options = options
        self.cornerRadius = cornerRadius
    }

    /**
     * Initializer to create a PDF image element.
     *
     * - Parameters:
     *      - image: Image which will be drawn
     *      - caption: Optional instance of a `PDFText` subclass, defaults to `nil`
     *      - size: Size of image, defaults to zero size
     *      - sizeFit: Defines how the image will fit if not enough space is given, defaults to `PDFImageSizeFit.widthHeight`
     *      - quality: JPEG quality between 0.0 and 1.0, defaults to 0.85
     *      - options: Defines if the image will be modified before rendering
     *      - cornerRadius: Defines the radius of the corners
     */
    public convenience init(
        image: Image,
        caption: PDFText? = nil,
        size: CGSize = .zero,
        sizeFit: PDFImageSizeFit = .widthHeight,
        quality: CGFloat = 0.85,
        options: PDFImageOptions = [.resize, .compress],
        cornerRadius: CGFloat? = nil
    ) {
        self.init(
            source: .image(image),
            caption: caption,
            size: size,
            sizeFit: sizeFit,
            quality: quality,
            options: options,
            cornerRadius: cornerRadius
        )
    }

    // MARK: - Resolution

    /// Decodes and returns the underlying ``Image``.
    ///
    /// For `.image` sources this is an O(1) operation.
    /// For `.fileURL` sources this performs a file I/O decode.
    /// Returns `nil` only for `.fileURL` sources when the file cannot be read.
    public func resolveImage() -> Image? {
        source.resolveImage()
    }

    // MARK: - Copy

    /// Creates a new `PDFImage` with the same properties
    public var copy: PDFImage {
        PDFImage(
            source: source,
            caption: caption?.copy,
            size: size,
            sizeFit: sizeFit,
            quality: quality,
            options: options,
            cornerRadius: cornerRadius
        )
    }

    // MARK: - Equatable

    /// nodoc
    override public func isEqual(to other: PDFDocumentObject) -> Bool {
        guard super.isEqual(to: other) else {
            return false
        }
        guard let otherImage = other as? PDFImage else {
            return false
        }
        guard attributes == otherImage.attributes else {
            return false
        }
        guard tag == otherImage.tag else {
            return false
        }
        guard sourcesAreEqual(source, otherImage.source) else {
            return false
        }
        guard caption == otherImage.caption else {
            return false
        }
        guard size == otherImage.size else {
            return false
        }
        guard sizeFit == otherImage.sizeFit else {
            return false
        }
        guard quality == otherImage.quality else {
            return false
        }
        return true
    }

    private func sourcesAreEqual(_ lhs: PDFImageSource, _ rhs: PDFImageSource) -> Bool {
        switch (lhs, rhs) {
        case (.image(let a), .image(let b)):
            return a == b
        case (.fileURL(let u1, let s1), .fileURL(let u2, let s2)):
            return u1 == u2 && s1 == s2
        default:
            return false
        }
    }

    // MARK: - Hashable

    /// nodoc
    override public func hash(into hasher: inout Hasher) {
        switch source {
        case .image(let img):
            hasher.combine(img)
        case .fileURL(let url, let sizeHint):
            hasher.combine(url)
            hasher.combine(sizeHint?.width)
            hasher.combine(sizeHint?.height)
        }
        hasher.combine(caption)
        hasher.combine(size.width)
        hasher.combine(size.height)
        hasher.combine(sizeFit)
        hasher.combine(quality)
        hasher.combine(options)
        hasher.combine(cornerRadius)
    }
}
