//
//  Resource.swift
//  test
//
//  Created by administrator on 27/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import Foundation

enum ResourceState {
    case new, IsDownloading, Downloaded, Failed, Cancelled, Cached;
}


/*
   Model to store all the data related to url string.
   It also contains information about who is observing resource.
 */
class Resource:NSObject
{
    let url:NSURLRequest
    var data:NSData?
    var state = ResourceState.new;
    
    var dataTask: NSURLSessionDataTask?
    var resumeData =  NSMutableData()
    
    var observers = [String:UrlObserverDelegate]()
    
    
    init(url:NSURLRequest)
    {
        self.url =  url;
    }
  
    /*
        adds observer to observers. This is used to send infromation about the data to observer
        once downlaod manager finishes its operation.
    */
    func addObserver(identifier:String, observer:UrlObserverDelegate){
        
        observers[identifier] = observer
    }
    
    /*
     when an observer no longer needs resource they can call this method by using the identifer 
     Identifier should be the same identifer which they used while creating.
    */
    func removeObserver(identifer:String)->UrlObserverDelegate?{
        let observer =  observers.removeValueForKey(identifer);
        return observer;
    }
    
}