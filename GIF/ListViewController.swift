 //
 //  ViewController.swift
 //  GIF
 //
 //  Created by Nick Lee on 9/4/14.
 //  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
 //
 
 import UIKit
 
 class ListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SSPullToRefreshViewDelegate, CellDelegate {
    
    // MARK: Properties
    
    var urls: [NSURL]?
    
    let cellHeight: CGFloat = 160.0
    
    let instructionLabelHeight: CGFloat = 44.0
    
    lazy var pullToRefreshView: SSPullToRefreshView = {
        let view = SSPullToRefreshView(scrollView: self.collectionView, delegate: self)
        return view
        }()
    
    lazy var pullToRefreshContentView: SSPullToRefreshSimpleContentView = {
        let view = SSPullToRefreshSimpleContentView()
        view.statusLabel.textColor = UIColor.whiteColor()
        view.statusLabel.font = UIFont(name: "Lato-Light", size: 17.0)
        view.activityIndicatorView.color = UIColor.whiteColor()
        return view
        }()
    
    lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.userInteractionEnabled = false
        label.text = "Pull down to create a gif"
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Lato-Light", size: 17.0)
        return label
        }()
    
    lazy var cellSize: CGSize = {
        
        let screen = UIScreen.mainScreen()
        let bounds = screen?.bounds
        let size = bounds?.size
        
        if var theSize = size {
            theSize.height = self.cellHeight
            return theSize
        }
        else {
            return CGSizeZero
        }
        
        }()
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.registerClass(Cell.self, forCellWithReuseIdentifier: NSStringFromClass(Cell))
        
        pullToRefreshView.contentView = pullToRefreshContentView
        
        collectionView.addSubview(instructionLabel)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadFiles()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        instructionLabel.frame = CGRect(x: 0, y: view.frame.height - instructionLabelHeight, width: view.frame.width, height: instructionLabelHeight)
    }
    
    // MARK: Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: File Management
    
    func reloadFiles() {
        getDocumentsDirectoryContents() { (urls: [NSURL]) -> () in
            
            self.urls = sorted(urls) { (a, b) -> Bool in
                return a.lastPathComponent > b.lastPathComponent
            }
            
            self.collectionView?.reloadData()
            
            
            
        }
    }
    
    func getDocumentsDirectoryContents(completion: ([NSURL]) -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            
            if let dataPath = NSFileManager.defaultManager().publicDataPath() {
                
                let dataURL = NSURL(string: dataPath)
                
                let contents = NSFileManager.defaultManager().contentsOfDirectoryAtURL(dataURL, includingPropertiesForKeys: [], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles | NSDirectoryEnumerationOptions.SkipsPackageDescendants | NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) as [NSURL]?
                
                let filtered = contents?.filter({ (url: NSURL) -> Bool in
                    
                    var isDirectory: ObjCBool = ObjCBool(0)
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(url.path!, isDirectory: &isDirectory) {
                        return !isDirectory.boolValue
                    }
                    
                    return false
                })
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if let array = filtered {
                        completion(array)
                    } else {
                        completion([])
                    }
                    
                })
                
            }
        })
    }
    
    // MARK: Pull To Refresh
    
    func pullToRefreshViewDidStartLoading(view: SSPullToRefreshView!) {
        showCamera(true)
    }
    
    // MARK: Camera Presentation
    
    func showCamera(animated: Bool) {
        let viewController = CameraViewController(nibName: "CameraViewController", bundle: NSBundle.mainBundle())
        
        viewController.openSession() {
            self.presentViewController(viewController, animated: animated) {
                self.pullToRefreshView.finishLoading()
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0;
        
        if let arr = urls {
            count = arr.count
        }
        
        return count
    }
    
    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        
        let cell = collectionView?.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(Cell), forIndexPath: indexPath) as Cell?
        
        let url = self.urls?[indexPath.item]
        
        cell?.delegate = self
        cell?.imageURL = url
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView!, shouldSelectItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }
    
    override func collectionView(collectionView: UICollectionView!, shouldHighlightItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return cellSize
    }
    
    // MARK: CellDelegate
    
    func cellTapped(cell: Cell) {
        
        let indexPath = collectionView.indexPathForCell(cell)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        
        let url = urls?[indexPath.item]
        
        cell.imageView.alpha = 0.5
        
        let cancelItem = RIButtonItem.itemWithLabel("Cancel") as RIButtonItem
        
        let copyItem = RIButtonItem.itemWithLabel("Copy to Clipboard", action: {
            
            copyAsyncToClipboard(url!)
            
        }) as RIButtonItem
        
        let deleteItem = RIButtonItem.itemWithLabel("Delete") as RIButtonItem
        deleteItem.action = {
            
            self.collectionView.performBatchUpdates({ () -> Void in
                NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
                let nsURLS: NSArray = self.urls!
                let urlIdx = nsURLS.indexOfObject(url!)
                self.urls?.removeAtIndex(urlIdx)
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
                }, completion: nil)
            
        }
        
        let actionSheet = UIActionSheet(title: nil, cancelButtonItem: cancelItem, destructiveButtonItem: deleteItem, otherButtonItem: copyItem)
        
        actionSheet.dismissalAction = {
            cell.imageView.alpha = 1.0
        }
        actionSheet.showInView(view.window)
    }
 }
 
