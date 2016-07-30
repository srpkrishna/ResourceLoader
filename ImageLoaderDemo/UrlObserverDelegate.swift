//
//  UrlObserverDelegate.swift
//  test
//
//  Created by Phani on 30/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import Foundation


/*

 This protocol specifies the methods that ResourceManager
 respond to class requesting for resource.
*/

@objc public protocol UrlObserverDelegate:NSObjectProtocol {
    
    /*
     This method is called when resource data is available for an url either from server
     or from cache. It is also used to communicate any problems in fetching the data for
     the resource.
    */
    func didFetchUrlData(urlString:String, data:NSData?, errorMessage:String)
    
    /*
     If you want use compressions on that data received from server before caching implement
     this method. The data for urlString is passed through data and expects compressed data by return
     type. For an Url use single compression technique. If multiple classes are using
     different compression techniques the this method does not guarantee which one it will implement
    */
    optional func compressData(urlString:String, data:NSData) -> NSData
    
    /*
     If you do not want to store data for a particular url in cache, return true else false.
     If multiple classes have requested for the same url data then all of them should implement
     this method and all of them should return false to avoid storing data in cache. If one of them doesn’t
     implement or return true then the data is stored in cache.
     */
    optional func shouldStoreDataInCache(urlString:String, data:NSData) -> Bool
}
