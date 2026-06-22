import MetalKit
import MosaicScrubberCore
import SwiftUI

#if os(macOS)
public struct MetalPreviewView: NSViewRepresentable {
    private let renderer: MetalPreviewRenderer

    public init(renderer: MetalPreviewRenderer) {
        self.renderer = renderer
    }

    public func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        renderer.configure(view: view)
        return view
    }

    public func updateNSView(_ nsView: MTKView, context: Context) {}
}
#else
public struct MetalPreviewView: UIViewRepresentable {
    private let renderer: MetalPreviewRenderer

    public init(renderer: MetalPreviewRenderer) {
        self.renderer = renderer
    }

    public func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        renderer.configure(view: view)
        return view
    }

    public func updateUIView(_ uiView: MTKView, context: Context) {}
}
#endif
