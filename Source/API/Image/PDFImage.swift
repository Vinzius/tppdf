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

    /**
     * Creates a `PDFImage` whose pixel data is supplied by a closure.
     *
     * A new ``UUID`` is generated and stored inside the ``PDFImageSource``
     * as the stable identity token for ``Equatable`` and ``Hashable``.
     * Two images created from separate calls to this initializer are therefore
     * never considered equal, even when the resolver closures produce identical
     * pixel data.
     *
     * If `size` is `.zero` the resolver is invoked **once at init time** to
     * obtain the image dimensions.  Pass an explicit `size` to defer all calls
     * to the resolver until draw time.
     *
     * - Parameters:
     *   - block:        Closure that returns the image on demand, or `nil` on failure.
     *                   May be called more than once (size probe + draw), so it
     *                   should be idempotent and side-effect-free.
     *   - size:         Layout size in points.  `.zero` triggers a size probe via
     *                   the resolver at init time.
     *   - caption:      Optional caption.
     *   - sizeFit:      Scaling behaviour when space is constrained.
     *   - quality:      JPEG compression quality (0.0 – 1.0).
     *   - options:      Image processing flags.
     *   - cornerRadius: Optional corner radius.
     */
    public convenience init(
        block resolver: @escaping () -> Image?,
        size: CGSize = .zero,
        caption: PDFText? = nil,
        sizeFit: PDFImageSizeFit = .widthHeight,
        quality: CGFloat = 0.85,
        options: PDFImageOptions = [.resize, .compress],
        cornerRadius: CGFloat? = nil
    ) {
        let sizeHint: CGSize? = size == .zero ? nil : size
        self.init(
            source: .block(id: UUID(), size: sizeHint, resolver: resolver),
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
    /// For `.block` sources this invokes the resolver closure.
    /// Returns `nil` when the source cannot produce an image.
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
        case (.block(let id1, _, _), .block(let id2, _, _)):
            return id1 == id2
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
        case .block(let id, _, _):
            hasher.combine(id)
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
