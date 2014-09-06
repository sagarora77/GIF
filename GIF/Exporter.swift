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

func rounded(input: Float) -> Float {
    return roundf(input * 100.0) / 100.0
}

class Exporter {
    
    var fps = 15
    var sourceURL: NSURL
    var destinationURL: NSURL
    var generator: AVAssetImageGenerator?
    
    lazy var operationQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init(sourceURL: NSURL, destinationURL: NSURL) {
        self.sourceURL = sourceURL
        self.destinationURL = destinationURL
    }
    
    func createGIF(progress: (progress: CGFloat) -> (), completion: () -> ()) {
        
        let asset = AVURLAsset(URL: sourceURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        let durationCMTime = asset.duration
        let duration = CMTimeGetSeconds(durationCMTime)
        let frameCount = Int(floor(duration * Float64(fps)))
        let frameDuration = Float(duration) / Float(frameCount)
        
        generator = AVAssetImageGenerator(asset: asset)
        generator?.requestedTimeToleranceAfter = kCMTimeZero
        generator?.requestedTimeToleranceBefore = kCMTimeZero
        
        let fileProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]]
        let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: rounded(frameDuration)]]
        
        let destination = CGImageDestinationCreateWithURL(self.destinationURL, kUTTypeGIF, UInt(frameCount), nil)
        CGImageDestinationSetProperties(destination, fileProperties)
        
        for i in 0..<frameCount {
            let time = Float64(frameDuration) * Float64(i)
            let timeCMTime = CMTimeMakeWithSeconds(time, durationCMTime.timescale)
            let image = generator?.copyCGImageAtTime(timeCMTime, actualTime: nil, error: nil)
            CGImageDestinationAddImage(destination, image, frameProperties)
        }
        
        CGImageDestinationFinalize(destination)
        
        NSOperationQueue.mainQueue().addOperationWithBlock(completion)
        
    }
    
}