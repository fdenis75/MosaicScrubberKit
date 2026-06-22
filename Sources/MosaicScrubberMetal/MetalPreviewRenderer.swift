import CoreVideo
import Foundation
import Logging
import Metal
import MetalKit
import MosaicScrubberCore
import OSLog

public final class MetalPreviewRenderer: NSObject, MTKViewDelegate, @unchecked Sendable {
    private struct Vertex {
        var position: SIMD2<Float>
        var texcoord: SIMD2<Float>
    }

    private let logger = Logger(label: "com.mosaicScrubber.metal-renderer")
    private let signposter = OSSignposter(subsystem: "com.mosaicScrubber", category: "metal-renderer")
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private let samplerState: MTLSamplerState
    private let bridge: PixelBufferTextureBridge

    private var currentFrame: PixelBufferMetalFrame?
    private var previousFrame: PixelBufferMetalFrame?
    private var transitionStart: CFTimeInterval = 0
    private var transitionDuration: TimeInterval

    public init(device: MTLDevice? = MTLCreateSystemDefaultDevice(), transitionDuration: TimeInterval = 0.12) throws {
        guard let device else { throw ScrubberError.metalUnavailable }
        self.device = device
        guard let commandQueue = device.makeCommandQueue() else {
            throw ScrubberError.rendererUnavailable("Could not create Metal command queue.")
        }
        self.commandQueue = commandQueue
        self.transitionDuration = transitionDuration
        self.bridge = try PixelBufferTextureBridge(device: device)

        let library = try Self.makeLibrary(device: device)
        guard let vertex = library.makeFunction(name: "scrubberVertex"),
              let fragment = library.makeFunction(name: "scrubberFragment") else {
            throw ScrubberError.rendererUnavailable("Could not load preview shader functions.")
        }

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertex
        descriptor.fragmentFunction = fragment
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        self.pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)

        let sampler = MTLSamplerDescriptor()
        sampler.minFilter = .linear
        sampler.magFilter = .linear
        sampler.sAddressMode = .clampToEdge
        sampler.tAddressMode = .clampToEdge
        guard let samplerState = device.makeSamplerState(descriptor: sampler) else {
            throw ScrubberError.rendererUnavailable("Could not create Metal sampler.")
        }
        self.samplerState = samplerState
        super.init()
    }

    @MainActor
    public func configure(view: MTKView) {
        view.device = device
        view.delegate = self
        view.colorPixelFormat = .bgra8Unorm
        view.framebufferOnly = true
        view.isPaused = false
        view.enableSetNeedsDisplay = false
        view.preferredFramesPerSecond = 60
    }

    public func update(pixelBuffer: CVPixelBuffer) {
        do {
            let newFrame = try bridge.makeFrame(from: pixelBuffer)
            previousFrame = currentFrame
            currentFrame = newFrame
            transitionStart = CACurrentMediaTime()
        } catch {
            logger.warning("Preview texture update failed: \(error.localizedDescription)")
        }
    }

    public func clear() {
        previousFrame = nil
        currentFrame = nil
        bridge.flush()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    public func draw(in view: MTKView) {
        guard let currentFrame,
              let descriptor = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }

        let state = signposter.beginInterval("Draw Preview")
        let vertices = Self.aspectFitVertices(
            textureSize: CGSize(width: currentFrame.texture.width, height: currentFrame.texture.height),
            drawableSize: view.drawableSize
        )

        var blend = transitionBlend()
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBytes(vertices, length: MemoryLayout<Vertex>.stride * vertices.count, index: 0)
        encoder.setFragmentTexture(currentFrame.texture, index: 0)
        if let previousFrame {
            encoder.setFragmentTexture(previousFrame.texture, index: 1)
        } else {
            blend = 1
        }
        encoder.setFragmentSamplerState(samplerState, index: 0)
        encoder.setFragmentBytes(&blend, length: MemoryLayout<Float>.stride, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
        encoder.endEncoding()

        let retainedCurrent = currentFrame
        let retainedPrevious = previousFrame
        commandBuffer.addCompletedHandler { [weak self] _ in
            _ = retainedCurrent
            _ = retainedPrevious
            self?.bridge.flush()
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        signposter.endInterval("Draw Preview", state)
    }

    private func transitionBlend() -> Float {
        guard previousFrame != nil, transitionDuration > 0 else { return 1 }
        let elapsed = CACurrentMediaTime() - transitionStart
        let value = min(max(elapsed / transitionDuration, 0), 1)
        if value >= 1 {
            previousFrame = nil
        }
        return Float(value)
    }

    private static func aspectFitVertices(textureSize: CGSize, drawableSize: CGSize) -> [Vertex] {
        guard textureSize.width > 0, textureSize.height > 0, drawableSize.width > 0, drawableSize.height > 0 else {
            return fullQuad
        }

        let textureAspect = textureSize.width / textureSize.height
        let drawableAspect = drawableSize.width / drawableSize.height
        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1

        if textureAspect > drawableAspect {
            scaleY = drawableAspect / textureAspect
        } else {
            scaleX = textureAspect / drawableAspect
        }

        return [
            Vertex(position: SIMD2(-Float(scaleX), -Float(scaleY)), texcoord: SIMD2(0, 1)),
            Vertex(position: SIMD2( Float(scaleX), -Float(scaleY)), texcoord: SIMD2(1, 1)),
            Vertex(position: SIMD2(-Float(scaleX),  Float(scaleY)), texcoord: SIMD2(0, 0)),
            Vertex(position: SIMD2( Float(scaleX),  Float(scaleY)), texcoord: SIMD2(1, 0))
        ]
    }

    private static let fullQuad: [Vertex] = [
        Vertex(position: SIMD2(-1, -1), texcoord: SIMD2(0, 1)),
        Vertex(position: SIMD2( 1, -1), texcoord: SIMD2(1, 1)),
        Vertex(position: SIMD2(-1,  1), texcoord: SIMD2(0, 0)),
        Vertex(position: SIMD2( 1,  1), texcoord: SIMD2(1, 0))
    ]

    private static func makeLibrary(device: MTLDevice) throws -> MTLLibrary {
        if let library = try? device.makeDefaultLibrary(bundle: .module) {
            return library
        }
        throw ScrubberError.rendererUnavailable("Could not load bundled Metal shader library.")
    }
}
