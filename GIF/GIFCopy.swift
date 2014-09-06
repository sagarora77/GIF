//
//  GIFCopy.swift
//  GIF
//
//  Created by Nick Lee on 9/5/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation

var GIFOperationQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
    }()

func copyAsyncToClipboard(url: NSURL) {
    
    let taskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
    
    GIFOperationQueue.addOperationWithBlock {
        
        let data = NSData(contentsOfURL: url)
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.setData(data, forPasteboardType: "com.compuserve.gif")
        
        UIApplication.sharedApplication().endBackgroundTask(taskID)
        
    }
}