//
//  ProgressView.swift
//  GIF
//
//  Created by Nick Lee on 9/5/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    var progress: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.55)
        return view
        }()

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if progressView.superview == nil {
            addSubview(progressView)
        }
        
        let width = round(progress * bounds.width)
        let frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        progressView.frame = frame
    }
    
}
