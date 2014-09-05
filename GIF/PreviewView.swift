//
//  PreviewView.swift
//  GIF
//
//  Created by Nick Lee on 9/5/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

import UIKit

protocol PreviewViewDelegate {
    func didDepressPreviewView(view: PreviewView)
    func didReleasePreviewView(view: PreviewView)
}

class PreviewView: UIView {

    var delegate: PreviewViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        delegate?.didDepressPreviewView(self)
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        delegate?.didReleasePreviewView(self)
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        delegate?.didReleasePreviewView(self)
    }
}
