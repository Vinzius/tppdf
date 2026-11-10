# Retinelle fork of TPPDF

This fork tracks [techprimate/TPPDF](https://github.com/techprimate/TPPDF) `main` and carries a few features used by Retinelle's PDF export.
The app pins an exact commit of this fork in `packages/inventory/Package.swift`.

## Fork-only changes

- `PDFImageSource` (`.image`, `.fileURL`, `.block`): lazy image sources so large exports don't keep every decoded photo in memory, plus `PDFImage` as table cell content.
- `PDFInfo.creator`: overrides the PDF "Creator" metadata instead of deriving it from the bundle name.

Fork-only tests live in their own files (`PDFImageSourceTests`, `PDFTableContentPDFImageTests`, `PDFInfoCreatorTests`) so upstream test changes don't conflict.

## Updating from upstream

```sh
git fetch upstream
git branch backup/main-pre-rebase-$(date +%F) main
git rebase upstream/main
swift test   # PDFInfoTests' "xctest" creator prefix fails under `swift test` upstream too; CI (xcodebuild) passes
xcodebuild -scheme TPPDF -destination 'generic/platform=watchOS Simulator' build   # catches missing imports on non-iOS platforms
git push --force-with-lease origin main
```

Then bump the pinned revision in the app's `packages/inventory/Package.swift` and its `Package.resolved` files.
