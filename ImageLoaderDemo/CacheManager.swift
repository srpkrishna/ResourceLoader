//
//  CacheManager.swift
//  test
//
//  Created by Phani on 29/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import Foundation

/*
 CacheManager manages cache for urlstring.
 It uses NSCache so that system can free the memory when the memory is tight
 lruCacheArray helps in implementing Least React Used cache.
*/

class CacheManager: NSObject,NSCacheDelegate{
    
    var cache:NSCache;
    var lruCacheArray:[String];
    
    override init()
    {
        
        self.cache = NSCache.init();
        self.lruCacheArray = [String]();
        super.init();
        self.cache.delegate = self;
    }
    
    /*
     For an urlString it finds out whether resource exists for an url
    */
    
    func getResource(urlString:String)->Resource?
    {
        if let resource = self.cache.objectForKey(urlString) as? Resource
        {
            if(self.lruCacheArray.contains(urlString))
            {
                let index = self.lruCacheArray.indexOf(urlString);
                self.lruCacheArray.removeAtIndex(index!);
                self.lruCacheArray.insert(urlString, atIndex: 0);
            }
            return resource;
        }
        
        return nil;
    }
    
    /*
      adds resource for cache. If the limit exceeds it deletes last element from cache
     */
    func addObject(resource:Resource)
    {
        let urlString = resource.url.URL?.absoluteString;
        
        if let resourceCache = getResource(urlString!) where resource.data != nil
        {
            
            //"Cache already contains object,overwriting content"
            resourceCache.data = NSData(data: resource.data!);
            
        }else if(getResource(urlString!) == nil)
        {
            if(self.lruCacheArray.count == self.cache.countLimit)
            {
                let urlString = self.lruCacheArray.removeLast();
                self.cache.removeObjectForKey(urlString);
            }
            
            self.cache.setObject(resource, forKey: urlString!);
            self.lruCacheArray.insert(urlString!,atIndex: 0);
        }
    }
    
    /*
     Removes an object from cache and update lruCacheArray
     */
    
    func removeObject(resource:Resource)
    {
        let urlString = resource.url.URL?.absoluteString;
        self.cache.removeObjectForKey(urlString!);
        if(self.lruCacheArray.contains(urlString!))
        {
            let index = self.lruCacheArray.indexOf(urlString!);
            self.lruCacheArray.removeAtIndex(index!);
        }
    }
    
    /*
     Removes all objects from cache and updates lruCacheArray
    */
    
    func clearCache()
    {
        self.cache.removeAllObjects();
        self.lruCacheArray.removeAll();
    }
    
    
    /*
     count will be the new Size of the Cache with respective number of elements.
     set new size limit to cache and lruCacheArray
    */
    func setMaximumLimit(count:Int)
    {
        var size = count;
        
        while(self.lruCacheArray.count > size){
            let urlString = self.lruCacheArray.removeLast();
            self.cache.removeObjectForKey(urlString);
            size = size - 1 ;
        }
        
        self.cache.countLimit = count;
        
        
    }
    
    /*
    when system clears element from cache this method is called wih deleted object obj
     updates lrucacheArray
    */
    func cache(cache: NSCache, willEvictObject obj: AnyObject)
    {
        if obj is Resource
        {
            let resource:Resource = obj as! Resource
            let urlString = resource.url.URL?.absoluteString;
            
            if(self.lruCacheArray.contains(urlString!))
            {
                let index = self.lruCacheArray.indexOf(urlString!);
                self.lruCacheArray.removeAtIndex(index!);
            }
        }
    }
}