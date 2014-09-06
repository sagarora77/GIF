//
//  CameraViewController.swift
//  GIF
//
//  Created by Nick Lee on 9/4/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, PreviewViewDelegate, SCRecorderDelegate {
    
    //MARK: Properties
    
    let maxTime: Float64 = 10.0
    let iconSize: CGFloat = 50.0
    let iconColor = UIColor.whiteColor()
    let disabledIconColor: UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    
    var elapsedTime: Float64 {
        let time = CMTimeGetSeconds(recordSession.currentRecordDuration)
            return min(time, maxTime)
    }
    
    var elapsedPercent: CGFloat {
        let pct = elapsedTime / maxTime
            return CGFloat(min(pct, Float64(1.0)))
    }
    
    var timeElapsed: Bool {
        return elapsedTime >= maxTime
    }
    
    lazy var recorder: SCRecorder = {
        let recorder = SCRecorder()
        recorder.sessionPreset = AVCaptureSessionPreset640x480
        recorder.delegate = self
        recorder.audioEnabled = false
        recorder.photoEnabled = false
        return recorder
        }()
    
    var exporter: Exporter?
    
    lazy var recordSession: SCRecordSession = {
        let session = SCRecordSession()
        session.videoSizeAsSquare = true
        return session
        }()
    
    lazy var avBackgroundQueue: dispatch_queue_t = {
        let queue = dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL)
        return queue
        }();
    
    lazy var numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = formatter.minimumFractionDigits
        return formatter
        }();
    
    lazy var closeIcon: FAKIonIcons = {
        let icon = FAKIonIcons.ios7BrowsersOutlineIconWithSize(self.iconSize - 4.0)
        icon.addAttribute(NSForegroundColorAttributeName, value: self.iconColor)
        return icon
        }()
    
    lazy var changeCameraIcon: FAKIonIcons = {
        let icon = FAKIonIcons.ios7ReverseCameraOutlineIconWithSize(self.iconSize)
        icon.addAttribute(NSForegroundColorAttributeName, value: self.iconColor)
        return icon
        }()
    
    lazy var saveIcon: FAKIonIcons = {
        let icon = FAKIonIcons.ios7DownloadOutlineIconWithSize(self.iconSize - 4.0)
        icon.addAttribute(NSForegroundColorAttributeName, value: self.iconColor)
        return icon
        }()
    
    lazy var changeCameraDisabledIcon: FAKIonIcons = {
        let icon = FAKIonIcons.ios7ReverseCameraOutlineIconWithSize(self.iconSize)
        icon.addAttribute(NSForegroundColorAttributeName, value: self.disabledIconColor)
        return icon
        }()
    
    lazy var saveDisabledIcon: FAKIonIcons = {
        let icon = FAKIonIcons.ios7DownloadOutlineIconWithSize(self.iconSize - 4.0)
        icon.addAttribute(NSForegroundColorAttributeName, value: self.disabledIconColor)
        return icon
        }()

    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var changeCameraButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        titleLabel.font = UIFont(name: "Lato-Light", size: 24.0)
        
        closeButton.setAttributedTitle(closeIcon.attributedString(), forState: UIControlState.Normal)
        
        changeCameraButton.setAttributedTitle(changeCameraIcon.attributedString(), forState: UIControlState.Normal)
        changeCameraButton.setAttributedTitle(changeCameraDisabledIcon.attributedString(), forState: UIControlState.Disabled)
        
        changeCameraButton.enabled = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 1
        
        saveButton.setAttributedTitle(saveIcon.attributedString(), forState: UIControlState.Normal)
        
        saveButton.setAttributedTitle(saveDisabledIcon.attributedString(), forState: UIControlState.Disabled)
        
        recorder.previewView = previewView
        
        previewView.delegate = self
        
        updateUI()
    }
    
    //MARK: Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.recorder.previewViewFrameChanged()
    }
    
    //MARK: Camera Initialization
    
    func openSession(completion: () -> ()) {
        recorder.openSession { (sessionError, audioError, videoError, photoError) -> Void in
            self.recorder.recordSession = self.recordSession
            dispatch_async(self.avBackgroundQueue, {
                self.recorder.startRunningSession()
                dispatch_async(dispatch_get_main_queue(), completion)
            })
        }
    }
    
    //MARK: Actions
    
    @IBAction func close(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            dispatch_async(self.avBackgroundQueue, {
                self.recorder.endRunningSession()
                self.recorder.closeSession()
            })
        })
    }
    
    @IBAction func rotateCamera(sender: UIButton) {
        recorder.switchCaptureDevices()
        recorder.previewViewFrameChanged()
    }
    
    @IBAction func save(sender: UIButton) {
        
        let documentsDir = NSFileManager.defaultManager().publicDataPath()
        let documentsDirURL = NSURL(fileURLWithPath: documentsDir)
        
        let seconds = Int(NSDate().timeIntervalSince1970)
        
        let gifOutputURL = documentsDirURL.URLByAppendingPathComponent("\(seconds)").URLByAppendingPathExtension("gif")
        
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)

        recorder.pause() {
            self.recordSession.endSession() { (error) -> Void in
                self.exporter = Exporter(sourceURL: self.recordSession.outputUrl, destinationURL: gifOutputURL)
                self.exporter?.createGIF({ (progress) -> () in
                }, completion: { () -> () in
                    hud.hide(true)
                    copyAsyncToClipboard(gifOutputURL)
                    self.dismissViewControllerAnimated(true, completion: nil);
                })
            }
        }
    }
    
    //MARK: UI Updates
    
    func updateUI() {
        progressView.progress = elapsedPercent
        
        let hasCaptured = elapsedTime > 0.0
        
        saveButton.enabled = hasCaptured
        
        if hasCaptured {
            titleLabel.text = numberFormatter.stringFromNumber(elapsedTime) + " seconds"
        }
        else {
            titleLabel.text = "Tap + Hold to Record"
        }

    }
    
    //MARK: Preview Delegate
    
    func didDepressPreviewView(view: PreviewView) {
        if !timeElapsed {
            self.recorder.record()
        }
    }
    
    func didReleasePreviewView(view: PreviewView) {
        
        if recorder.isRecording {
            self.recorder.pause()
        }
        
        updateUI()
    }
    
    //MARK: Recorder Delegate
    
    func recorder(recorder: SCRecorder!, didAppendVideoSampleBuffer recordSession: SCRecordSession!) {
        
        if timeElapsed {
            recorder.pause()
        }
        
        updateUI()
    }
 
    func recorder(recorder: SCRecorder!, didEndRecordSegment recordSession: SCRecordSession!, segmentIndex: Int, error: NSError!) {
        updateUI()
    }
    
}
