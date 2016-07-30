//
//  DownloadOperationsQueue.swift
//  test
//
//  Created by administrator on 27/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import Foundation


/*
    this protocal collects information from all the following delegates NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate.
    Sends back to implemementer the download information of url string.
 
 */
protocol DownloadsManagerDelegate {
    func downloadComplete(resource:Resource, errorMessage:String);
}


/*
    This class fetches all types of data from server.
    It also controls the download tasks. 
    All the download operations can be controlled through downloadQueue
 */

class DownloadsManager:NSObject,NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate
{
    
    lazy var downloadsInProgress = [String:Resource]()
    lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Download queue"
        return queue
    }()
    
    let downloaderConfig:NSURLSessionConfiguration
    let delegate:DownloadsManagerDelegate
    
    /*
        Initialises with session information from downloaderConfig
    */
    init(downloaderConfig:NSURLSessionConfiguration,delegate:DownloadsManagerDelegate) {
        self.downloaderConfig = downloaderConfig;
        self.delegate = delegate;
    }
    
    /*
     This method intilizes download operation for urlString (which is associated with resource)
     It pushes the resource to downloadsInProgress for quick access of status of resource
    */
    func startDataTask(resource:Resource)
    {
        let session = NSURLSession(configuration: downloaderConfig, delegate: self, delegateQueue: downloadQueue)
        resource.dataTask = session.dataTaskWithRequest(resource.url);
        downloadsInProgress[(resource.url.URL?.absoluteString)!] = resource;
        resource.dataTask!.resume();
        resource.state = ResourceState.IsDownloading;
        
        
    }
    
    /*
        cancels downloading the data opearation from server , update downloadsInProgress
        and notifies the deleagte
    */
    func cancelDataTask(resource:Resource)
    {
        if let dataTask = resource.dataTask
        {
            dataTask.cancel();
            resource.state = .Cancelled;
            if let urlString  = resource.url.URL?.absoluteString
            {
                downloadsInProgress.removeValueForKey(urlString);
            }
            
        }
        
    }
    
    
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        let urlString = dataTask.originalRequest?.URL?.absoluteString;
        
        if let resource = downloadsInProgress[urlString!]
        {
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                let error = String("Server call failed with status code ",(response as? NSHTTPURLResponse)?.statusCode , "for url: ",urlString);
                dataTask.cancel();
                resource.resumeData = NSMutableData();
                resource.state = ResourceState.Failed;
                downloadsInProgress.removeValueForKey(urlString!);
                self.delegate.downloadComplete(resource, errorMessage:error);
                
                return
                
            }
            
            completionHandler(NSURLSessionResponseDisposition.Allow) //.Cancel,If you want to stop the download
            
        }else
        {
            dataTask.cancel();
        }

        
        
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?){
        
        let urlString = task.originalRequest?.URL?.absoluteString;
        if let resource = downloadsInProgress[urlString!]
        {
            downloadsInProgress.removeValueForKey(urlString!);
            if(error == nil)
            {
                resource.data = NSData.init(data: resource.resumeData);
                resource.resumeData = NSMutableData();
                resource.state = ResourceState.Downloaded;
                self.delegate.downloadComplete(resource, errorMessage: "");
                
            }else
            {
                resource.resumeData = NSMutableData();
                resource.state = ResourceState.Failed;
                let error = String("Server call failed with internal error for url: ",urlString);
                self.delegate.downloadComplete(resource, errorMessage: error);
            }
            
        }
    }
    
    
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData){
        
        let urlString = dataTask.originalRequest?.URL?.absoluteString;
        
        if let resource = downloadsInProgress[urlString!]
        {
            resource.resumeData.appendData(data);
        }else
        {
            dataTask.cancel();
        }
        
    }
    
    
}


