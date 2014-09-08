//
//  GIFCopy.swift
//  GIF
//
//  Created by Nick Lee on 9/5/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation

let GIFType = "com.compuserve.gif"

var GIFOperationQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
    }()

var GIFCache: NSCache = {
    let cache = NSCache()
    cache.countLimit = 25
    return cache
    }()

func copyAsyncToClipboard(url: NSURL) {
    
    let taskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
    
    GIFOperationQueue.addOperationWithBlock {
        
        let data = NSData(contentsOfURL: url)
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.setData(data, forPasteboardType: GIFType)
        
        UIApplication.sharedApplication().endBackgroundTask(taskID)
        
    }
}