//
//  Exporter.swift
//  GIF
//
//  Created by Nick Lee on 9/5/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import AVFoundation
import ImageIO
import MobileCoreServices
import CoreMedia

func rounded(input: Float) -> Float {
    return roundf(input * 100.0) / 100.0
}

class Exporter {
    
    var fps = 15
    let tolerance: Float64 = 0.02
    var sourceURL: NSURL
    var destinationURL: NSURL
    var maximumSize = CGSize(width: 180, height: 180)
    var generator: AVAssetImageGenerator?
    
    init(sourceURL: NSURL, destinationURL: NSURL) {
        self.sourceURL = sourceURL
        self.destinationURL = destinationURL
    }
    
    func createGIF(progress: (progress: CGFloat) -> (), completion: () -> ()) {
        
        GIFOperationQueue.addOperationWithBlock() {
            
            let asset = AVURLAsset(URL: self.sourceURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
            
            let durationCMTime = asset.duration
            let duration = CMTimeGetSeconds(durationCMTime)
            let frameCount = Int(floor(duration * Float64(self.fps)))
            let frameDuration = Float(duration) / Float(frameCount)
            
            self.generator = AVAssetImageGenerator(asset: asset)
            
            let tolerance = CMTimeMakeWithSeconds(self.tolerance, durationCMTime.timescale)
            
            self.generator?.requestedTimeToleranceAfter = tolerance
            self.generator?.requestedTimeToleranceBefore = tolerance
            
            self.generator?.maximumSize = self.maximumSize
            
            let fileProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]]
            let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: rounded(frameDuration)]]
            
            let destination = CGImageDestinationCreateWithURL(self.destinationURL, kUTTypeGIF, UInt(frameCount), nil)
            CGImageDestinationSetProperties(destination, fileProperties)
            
            for i in 0..<frameCount {
                let time = Float64(frameDuration) * Float64(i)
                let timeCMTime = CMTimeMakeWithSeconds(time, durationCMTime.timescale)
                let image = self.generator?.copyCGImageAtTime(timeCMTime, actualTime: nil, error: nil)
                CGImageDestinationAddImage(destination, image, frameProperties)
            }
            
            CGImageDestinationFinalize(destination)
            
            NSOperationQueue.mainQueue().addOperationWithBlock(completion)
        }
        
    }
    
}