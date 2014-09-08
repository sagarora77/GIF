//
//  Cell.swift
//  GIF
//
//  Created by Nick Lee on 9/4/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

import UIKit

protocol CellDelegate {
    func cellTapped(cell: Cell)
}

class Cell : UICollectionViewCell {
    
    // MARK: Properties
    
    var delegate: CellDelegate?
    
    weak var imageLoadOperation: NSBlockOperation?
    
    lazy var imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        return imageView
        }()
    
    var imageURL: NSURL? {
        didSet {
            if let url = imageURL {
                
                let blockOperation = NSBlockOperation()
                weak var weakBlockOperation = blockOperation
                
                blockOperation.addExecutionBlock() {
                    
                    if let strongOperation = weakBlockOperation {
                        
                        var image: FLAnimatedImage? = GIFCache.objectForKey(url) as? FLAnimatedImage
                        
                        if image == nil {
                            
                            if strongOperation.cancelled {
                                return
                            }
                            
                            let data = NSData(contentsOfURL: url)
                            
                            if strongOperation.cancelled {
                                return
                            }
                            
                            let animatedImage = FLAnimatedImage(animatedGIFData: data)
                            
                            if strongOperation.cancelled {
                                return
                            }
                            
                            GIFCache.setObject(animatedImage, forKey: url)
                            
                            image = animatedImage
                        }
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            self.imageView.animatedImage = image
                            self.backgroundColor = UIColor.whiteColor()
                        }
                    }
                }
                
                imageLoadOperation = blockOperation
                
                GIFOperationQueue.addOperation(blockOperation)
                
            }
        }
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor()
        contentView.addSubview(imageView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        if let operation = imageLoadOperation {
            operation.cancel()
            imageLoadOperation = nil
        }
        
        imageView.animatedImage = nil
        
        backgroundColor = UIColor.blackColor()
    }
    
    // MARK: Overrides
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        imageView.alpha = 0.5
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        imageView.alpha = 1.0
        super.touchesEnded(touches, withEvent: event)
        delegate?.cellTapped(self)
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        imageView.alpha = 1.0
        super.touchesCancelled(touches, withEvent: event)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
}

