//
//  ViewController.swift
//  test
//
//  Created by administrator on 26/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import UIKit
import CoreImage


struct  SCREEN_CONSTANTS {
    static let VIEWCONTROLLER_IDENTIFIER = "viewcontroller_identifier"
    static let CELL_HEIGHT: CGFloat = 10
}


class ViewController: UITableViewController, UrlObserverDelegate {
    
    lazy var photos:NSDictionary! = NSDictionary()
    var resourceManager:ResourceManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Classic Photos"
        loadPhotos()
        resourceManager = ResourceManager.init(configuration: nil);
    }
    
    
    func loadPhotos(){
        let flickr:FlickrHelper = FlickrHelper()
        flickr.searchFlickrForString("nature") { (searchString, flickrPhotos, error) in
            if error == nil{
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.photos = flickrPhotos
                    self.tableView.reloadData()
                    
                })
            }
            
        }
    }
    
    
    // #pragma mark - Table view data source
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath)
        let rowKey = photos.allKeys[indexPath.row] as! String
        
        let url = (photos.valueForKey(rowKey) as? String)!;
        
        
        //self.resourceManager.getDataFor(url, withIdentifier: "CellIdentifier",withUrlObserver: self);
        
        if (!tableView.dragging && !tableView.decelerating) {
            self.resourceManager.getDataFor(url, withIdentifier: SCREEN_CONSTANTS.VIEWCONTROLLER_IDENTIFIER,withUrlObserver: self);
        }
        
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        indicator.startAnimating();
        
        // Configure the cell...
        cell.textLabel?.text = String(indexPath.row+1) + ". " + rowKey;
        cell.textLabel?.textColor = UIColor.blackColor();
        cell.imageView?.image = UIImage(named: "Placeholder");
        
        //self.resourceManager.cancelDataFor(url, withIdentifier: "CellIdentifier");
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView.frame.size.height / SCREEN_CONSTANTS.CELL_HEIGHT
    }
    
    func compressData(urlString:String, data:NSData) -> NSData
    {
        let unfilteredImage = UIImage(data:data)
        let image = self.applySepiaFilter(unfilteredImage!)
        return UIImagePNGRepresentation(image!)!;
    }
    
    func applySepiaFilter(image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(0.8, forKey: "inputIntensity")
        if let outputImage = filter!.outputImage {
            let outImage = context.createCGImage(outputImage, fromRect: outputImage.extent)
            return UIImage(CGImage: outImage)
        }
        return nil
        
    }
    
    func didFetchUrlData(urlString:String, data:NSData?, errorMessage:String)
    {
        
        var image : UIImage?
        
        if let imageData = data
        {
            image = UIImage(data:imageData)
            //image = self.applySepiaFilter(unfilteredImage!)
        }
        
        let array = photos.allValues as NSArray
        
        let index = array.indexOfObject(urlString);
        
        let indexPath = NSIndexPath.init(forRow: index, inSection: 0);
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath)
        {
            let indicator = cell.accessoryView as! UIActivityIndicatorView
            
            
            
            dispatch_async(dispatch_get_main_queue(), {
                if let filImage = image
                {
                    cell.imageView?.image = filImage
                    
                }else
                {
                    cell.textLabel?.text = String(indexPath.row+1) + ". " + (self.photos.allKeys[indexPath.row] as! String) + " - " + errorMessage;
                    cell.textLabel?.textColor = UIColor.redColor();
                }
                indicator.stopAnimating();
            })
        }
        
    }
    
}


extension ViewController
{
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        for (_, value) in self.photos{
            self.resourceManager.cancelDataFor((value as? String)!, withIdentifier: SCREEN_CONSTANTS.VIEWCONTROLLER_IDENTIFIER)
        }
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        
    }
    
    func loadImagesForOnscreenCells () {
        
        if let pathsArray = self.tableView.indexPathsForVisibleRows{
            for indexpath in pathsArray{
                let rowKey = photos.allKeys[indexpath.row] as! String
                let url = (photos.valueForKey(rowKey) as? String)!;
                self.resourceManager.getDataFor(url, withIdentifier: SCREEN_CONSTANTS.VIEWCONTROLLER_IDENTIFIER, withUrlObserver: self)
            }
        }
        
    }
}



