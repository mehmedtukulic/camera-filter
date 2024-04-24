import AVKit
import CoreImage
import Foundation

struct SampleBufferTransformer {
    func transform(videoSampleBuffer: CMSampleBuffer) -> CMSampleBuffer {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(videoSampleBuffer) else {
            print("failed to get pixel buffer")
            fatalError()
        }
        
        let context = CIContext(options: nil)
        let filter = "CIColorInvert"

        // CIImage from buffer
        let ciImage = CIImage(cvImageBuffer: imageBuffer)

        // Invert the colors
        let ciImageInverted = ciImage.applyingFilter(filter, parameters: [:])

        // Lock the buffer
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))

        // Render the inverted CIImage into the buffer
        context.render(ciImageInverted, to: imageBuffer)

        // Unlock the buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))

        guard let result = try? imageBuffer.mapToSampleBuffer(timestamp: videoSampleBuffer.presentationTimeStamp) else {
            fatalError()
        }

        return result
    }
}
