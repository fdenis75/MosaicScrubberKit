import CoreGraphics
import SwiftUI

#if canImport(AppKit)
import AppKit

extension Image {
    init(cgImage: CGImage) {
        self.init(nsImage: NSImage(cgImage: cgImage, size: .zero))
    }
}
#elseif canImport(UIKit)
import UIKit

extension Image {
    init(cgImage: CGImage) {
        self.init(uiImage: UIImage(cgImage: cgImage))
    }
}
#endif
