import CoreGraphics
import SwiftUI

// UIKit is checked first on purpose: Mac Catalyst can import AppKit, but
// SwiftUI's `Image(nsImage:)` is unavailable there, while `Image(uiImage:)` is.
#if canImport(UIKit)
import UIKit

extension Image {
    init(cgImage: CGImage) {
        self.init(uiImage: UIImage(cgImage: cgImage))
    }
}
#elseif canImport(AppKit)
import AppKit

extension Image {
    init(cgImage: CGImage) {
        self.init(nsImage: NSImage(cgImage: cgImage, size: .zero))
    }
}
#endif
