//
//  Cell.swift
//  GIF
//
//  Created by Nick Lee on 9/4/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

import UIKit

class Cell : UICollectionViewCell {
    
    // MARK: Properties
    
    lazy var imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        return imageView
        }()
    
    lazy var blurEffect: UIBlurEffect = {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        return effect
        }();
    
    lazy var blurryView: UIVisualEffectView = {
        let blurryView = UIVisualEffectView(effect: self.blurEffect)
        blurryView.alpha = 0.0
        return blurryView
        }()
    
    var imageURL: NSURL? {
        didSet {
            if let url = imageURL {
                let data = NSData(contentsOfURL: url)
                let animatedImage = FLAnimatedImage(animatedGIFData: data)
                imageView.animatedImage = animatedImage
            }
        }
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(blurryView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        blurryView.frame = bounds
    }
    
}

