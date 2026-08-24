//
//  PDFInfoCreatorTests.swift
//  TPPDF
//
//  Copyright © 2016-2026 techprimate GmbH. All rights reserved.
//

import CoreGraphics
import Foundation
import Testing
@testable import TPPDF

struct PDFInfoCreatorTests {
    @Test func explicitCreatorOverridesBundleDerivedValue() {
        let info = PDFInfo(creator: "Retinelle 1.0")

        #expect(info.generate()[kCGPDFContextCreator as String] as? String == "Retinelle 1.0")
    }

    @Test func missingCreatorFallsBackToBundleNameAndVersion() {
        let info = PDFInfo()
        let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "TPPDF"
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

        #expect(info.creator == nil)
        #expect(info.generate()[kCGPDFContextCreator as String] as? String == "\(bundleName) \(bundleVersion)")
    }
}

extension PDFInfoCreatorTests {
    @Test func infosWithDifferentCreatorsAreUnequal() {
        #expect(PDFInfo(creator: "A") == PDFInfo(creator: "A"))
        #expect(PDFInfo(creator: "A") != PDFInfo(creator: "B"))
        #expect(PDFInfo(creator: "A") != PDFInfo())
    }
}
