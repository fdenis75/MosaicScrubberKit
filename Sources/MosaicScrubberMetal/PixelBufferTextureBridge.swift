import CoreVideo
import Foundation
import Metal
import MosaicScrubberCore

public final class PixelBufferMetalFrame: @unchecked Sendable {
    public let pixelBuffer: CVPixelBuffer
    public let cvTexture: CVMetalTexture
    public let texture: MTLTexture

    init(pixelBuffer: CVPixelBuffer, cvTexture: CVMetalTexture, texture: MTLTexture) {
        self.pixelBuffer = pixelBuffer
        self.cvTexture = cvTexture
        self.texture = texture
    }
}

public final class PixelBufferTextureBridge: @unchecked Sendable {
    private let device: MTLDevice
    private var textureCache: CVMetalTextureCache?

    public init(device: MTLDevice) throws {
        self.device = device
        var cache: CVMetalTextureCache?
        let status = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache)
        guard status == kCVReturnSuccess, let cache else {
            throw ScrubberError.rendererUnavailable("Could not create CVMetalTextureCache.")
        }
        self.textureCache = cache
    }

    public func makeFrame(from pixelBuffer: CVPixelBuffer) throws -> PixelBufferMetalFrame {
        guard let textureCache else {
            throw ScrubberError.rendererUnavailable("Texture cache was released.")
        }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var cvTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &cvTexture
        )

        guard status == kCVReturnSuccess,
              let cvTexture,
              let texture = CVMetalTextureGetTexture(cvTexture) else {
            throw ScrubberError.rendererUnavailable("Could not create Metal texture from pixel buffer.")
        }

        return PixelBufferMetalFrame(pixelBuffer: pixelBuffer, cvTexture: cvTexture, texture: texture)
    }

    public func flush() {
        if let textureCache {
            CVMetalTextureCacheFlush(textureCache, 0)
        }
    }
}
