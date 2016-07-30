//
//  ResourceManger.swift
//  test
//
//  Created by administrator on 27/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import Foundation

/*
 This class loads all the resources you need from http/https.
 It has two important components one is downloadsManager and  other is CacheManager.
 
 Whenever an url is submitted it checks whether corresponding resource is there in Cache
 using CacheManager. If it doesn’t find resource in cache it checks wether that resource is
 already downloading by DownloadManager. It it doesn’t find then it creates Resource and
 initialises download for that resource. It also add observers for that resource.
 
 If the resource is found in cache , it send back the resource data to observer. If the resource
 is found in DownloadManger  then it adds the observer to resource observer list.
 
 The class takes input of NSURLSessionConfiguration so that you can set your authentication
 and other session related parameters.
 
 You can control async operations  using maxOperationsCount and number of items in cache by
 cacheResourcesCount and by cacheMaxSize

 
 */
public class ResourceManager:NSObject,DownloadsManagerDelegate
{
    
    private var downloadsManager:DownloadsManager!;
    private var cacheManager:CacheManager!;
    
    /*
     controls concurrent operations that downloadmanger can use to download resources
    */
    public var maxOperationsCount:Int{
        
        get{
            return self.downloadsManager.downloadQueue.maxConcurrentOperationCount;
        }
        
        set(value){
            self.downloadsManager.downloadQueue.maxConcurrentOperationCount = value;
        }
    }
    
    
    /*
     controls resources count that can store in  Cache
     */
    
    public var cacheResourcesCount:Int{
        
        get{
            return self.cacheManager.cache.countLimit;
        }
        
        set(value){
            self.cacheManager.setMaximumLimit(value);
        }
    }
    
    /*
      controls the total size of resources in cache
     */
    public var cacheMaxSize:Int{
        get{
            return self.cacheManager.cache.totalCostLimit;
        }
        
        set(value){
            self.cacheManager.cache.totalCostLimit = value;
        }
    }
    
    
    /*
        Download manager uses this NSURLSessionConfiguration to download all the data for an url.
        To avoid authenication problems set details in configuration
    */
    public init(configuration:NSURLSessionConfiguration?)
    {
        super.init();
        
        if let config = configuration
        {
            self.downloadsManager = DownloadsManager.init(downloaderConfig: config, delegate: self);
            
        }else
        {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration();
            self.downloadsManager = DownloadsManager.init(downloaderConfig: configuration, delegate: self);
        }
        
        cacheManager = CacheManager.init();
        
        self.cacheResourcesCount = 50;
        self.maxOperationsCount = 10;
        
    }
    
    /*
     
     This method checks whether a particular resource information is already there with resource manager.
     It checks for given urlString whether a resource exists with CacheManager (in cache) or with DownlaodManager
     (currently downlaoding). If found in cache it sends data back using observer or if it finds in download queue
     it adds observer to resource.
     
     if not found return false
    */
    private func doNeedfulIfResourceExists(urlString:String, _ identifier:String, _ observer:UrlObserverDelegate)->Bool
    {
        var resourceFound = false;
        
        if let resource = self.downloadsManager.downloadsInProgress[urlString]
        {
            resource.addObserver(identifier, observer: observer)
            resourceFound = true;
        }
        else if let resource = self.cacheManager.getResource(urlString)
        {
            let data =  NSData.init(data: resource.data!)
            
            dispatch_async(dispatch_get_main_queue()){
                observer.didFetchUrlData(urlString,data: data,errorMessage: "");
            }
            
            resourceFound = true;
            
        }
    
        return resourceFound;
    }
    
    
    /*
     urlString is used to check whether a resource exists, if not creates new resource.
     identifier is used add observers to a resource. If the calling object doesnt need data 
     then it can use this to remove observers.
     
     observer is used to commuinicate back the status of data fetch from cache or from server
     
    */
    public func getDataFor(urlString:String, withIdentifier identifier:String, withUrlObserver observer:UrlObserverDelegate)
    {
        if let url =  NSURL(string:urlString)
        {
            
            if(!doNeedfulIfResourceExists(urlString,identifier,observer))
            {
                let resource = Resource.init(url: NSURLRequest.init(URL: url));
                resource.addObserver(identifier, observer: observer);
                self.downloadsManager.startDataTask(resource);
            }
            
            
        }else
        {
            dispatch_async(dispatch_get_main_queue()){
                observer.didFetchUrlData(urlString,data: nil,errorMessage: "Improper url");
            }
        }
    }
    
    /*
     It is same as getDataFor except it takes urlRequest as input so that you have more control on request
     like adding custom headers or for changing request method.
    */
    
    public func getDataForNSURLRequest(urlRequest:NSURLRequest, withIdentifier identifier:String, withUrlObserver observer:UrlObserverDelegate){
        
        if let urlString = urlRequest.URL?.absoluteString
        {
            if let resource = self.downloadsManager.downloadsInProgress[urlString]
            {
                resource.addObserver(identifier, observer: observer)
                
            }else
            {
                let resource = Resource.init(url: urlRequest);
                resource.addObserver(identifier, observer: observer);
                self.downloadsManager.startDataTask(resource);
            }
        }
    }
    
    /*
     This method is used to force fetch data from server. 
     If the resource exists in cache, the new data fetched overrites the resource data in cache
     */
    
    public func getDataFromServer(urlString:String, withIdentifier identifier:String, withUrlObserver observer:UrlObserverDelegate)
    {
        if let url =  NSURL(string:urlString)
        {
            
            if let resource = self.downloadsManager.downloadsInProgress[urlString]
            {
                resource.addObserver(identifier, observer: observer);
                
            }else
            {
                let resource = Resource.init(url: NSURLRequest.init(URL: url));
                resource.addObserver(identifier, observer: observer);
                self.downloadsManager.startDataTask(resource);
            }
            
            
        }else
        {
            dispatch_async(dispatch_get_main_queue()){
                observer.didFetchUrlData(urlString,data: nil,errorMessage: "Improper url");
            }
        }

    }
    
    /*
     Gets the data related to url if found in cache else return nil
     */
    
    public func getDataFromCache(urlString:String)->NSData?
    {
        var cachedData:NSData?
        if let resource = self.cacheManager.getResource(urlString)
        {
            cachedData =  NSData.init(data: resource.data!)
        }
        
        return cachedData;
    }
    
    
    /*
 
     if the resource for an urlString is not needed you can de observer your self using this method.
     identifier the same identifier with which you requested of data.
     
    */
    public func cancelDataFor(urlString:String, withIdentifier identifier:String)
    {
        if let resource = self.downloadsManager.downloadsInProgress[urlString]
        {
            if let observer = resource.removeObserver(identifier)
            {
                let error = String("Download call cancelled for url: ",urlString);
                dispatch_async(dispatch_get_main_queue()){
                    observer.didFetchUrlData(urlString,data: nil,errorMessage: error);
                }
            }
            if(resource.observers.count == 0 )
            {
                self.downloadsManager.cancelDataTask(resource);
            }
            self.downloadsManager.downloadsInProgress.removeValueForKey(urlString)
            
        }
        
    }
    
    /*
     
     Same as cancelDataFor(:) just it takes NSURLRequest from which it again fethces the url and
     uses identifier to remove observers
     */
    public func cancelDataForNSURLRequest(urlRequest:NSURLRequest, withIdentifier identifier:String)
    {
        if let urlString = urlRequest.URL?.absoluteString
        {
            cancelDataFor(urlString, withIdentifier: identifier);
        }
        
    }

    
    
    /*
     clears all the elements from cache
    */
    public func clearCache()
    {
        self.cacheManager.clearCache();
    }
    
    /*
        clears all pending downloads, also will clear all the resources associated with urls.
        doesn't triger delegate methods updating the cancel status.
    */
    public func cancelAllDownloads()
    {
        self.downloadsManager.downloadQueue.cancelAllOperations();
        self.downloadsManager.downloadsInProgress.removeAll();
    }
    
}

extension ResourceManager: NSURLSessionDelegate {
    
    func downloadComplete(resource:Resource, errorMessage:String)
    {
    
        let urlString = (resource.url.URL?.absoluteString)!;
        
        if let data = resource.data where resource.state == .Downloaded
        {
            
            var compressedData:NSData!;
            
            for (_,observer) in resource.observers
            {
                compressedData = observer.compressData?(urlString, data: data);
                
                if(compressedData != nil && compressedData.length > 0)
                {
                    break;
                }
            }
            
            if(compressedData == nil)
            {
                compressedData = NSData(data:data);
            }
            
            
            var storeInCache = false;
            for (_,observer) in resource.observers
            {
                if(!storeInCache)
                {
                    if(observer.shouldStoreDataInCache == nil)
                    {
                        storeInCache = true;
                        
                    }else if(observer.shouldStoreDataInCache!(urlString, data: data))
                    {
                        storeInCache = true;
                    }
                }
                observer.didFetchUrlData(urlString,data:compressedData,errorMessage: errorMessage);
            }
            
            if(storeInCache)
            {
                resource.state =  ResourceState.Cached;
                resource.data = NSData(data:compressedData);
                self.cacheManager.addObject(resource);
            }
            
        }else
        {
            
            var msg = errorMessage
            if(msg == "")
            {
                msg = "Some internal error occured, Data downlaoded is zero for url: "+urlString;
            }
            
            for (_,observer) in resource.observers
            {
                
                observer.didFetchUrlData(urlString,data:nil,errorMessage: msg);
            }
            
        }
        
        resource.observers.removeAll();
    }
}