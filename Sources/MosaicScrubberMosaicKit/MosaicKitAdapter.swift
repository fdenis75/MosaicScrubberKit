import AVFoundation
import CoreGraphics
import Foundation
import MosaicKit
import MosaicScrubberCore
import MosaicScrubberKit

extension ScrubberVideoSource {
    public init(videoInput: VideoInput) {
        let naturalSize: CGSize?
        if let width = videoInput.width, let height = videoInput.height {
            naturalSize = CGSize(width: width, height: height)
        } else {
            naturalSize = nil
        }

        self.init(
            id: videoInput.id,
            url: videoInput.url,
            duration: videoInput.duration,
            naturalSize: naturalSize,
            frameRate: videoInput.frameRate,
            title: videoInput.title
        )
    }
}
