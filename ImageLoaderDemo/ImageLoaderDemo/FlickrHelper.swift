//
//  FlickrHelper.swift
//  test
//
//  Created by administrator on 27/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import Foundation

import Foundation


class FlickrHelper{
    
    class func URLForSearchString (searchString:String!) -> String{
        let apiKey:String = "c1fd85182d387125461f7d4c57069269"        
        let search: String = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.whitespaceCharacterSet())!
        
        let url: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(search)&per_page=100&format=json&nojsoncallback=1"
        return url
    }
    
    class func URLForFlickrPhoto(photo:FlickrPhoto, size:String) -> String{
        
        var _size:String = size
        
        if _size.isEmpty{
            _size = "s"
        }
        
        return "http://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.photoID)_\(photo.secret)_\(_size).jpg"
        
    }
    
    func searchFlickrForString(searchStr:String, completion:(searchString:String!, flickrPhotos: [String: String]!, error:NSError!)->()){
        
        let searchURL:String = FlickrHelper.URLForSearchString(searchStr)
        let queue:dispatch_queue_t  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        
        dispatch_async(queue) {
           // var error:NSError?
            let searchResultString: String?
            do {
                searchResultString = try String(contentsOfURL: NSURL(string: searchURL)!)
            } catch _ {
                searchResultString = nil
            }
            
            // Parse JSON Response
            let jsonData:NSData! = searchResultString!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            let resultdict: NSDictionary!
            do{
                resultdict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableLeaves) as! NSDictionary
            }catch _{
                resultdict = nil
            }
            
            //let resultDict:NSDictionary! = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil)
            
            
            let statusString = resultdict.objectForKey("stat") as! String
            
            if statusString == "fail"{
                
                let messageString:String = resultdict.objectForKey("message") as! String
                let error:NSError? = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:messageString])
                
                
                completion(searchString: searchStr, flickrPhotos: nil, error:error )
            }else{
                let photosDict:NSDictionary = resultdict.objectForKey("photos") as! NSDictionary
                let resultArray:NSArray = photosDict.objectForKey("photo") as! NSArray
                
                var flickrPhotos: [String: String] = [:]
                
                for photoObject in resultArray{
                    let photoDict:NSDictionary = photoObject as! NSDictionary
                    //print(photoDict)
                    let flickrPhoto:FlickrPhoto = FlickrPhoto()
                    flickrPhoto.farm = photoDict.objectForKey("farm") as! Int
                    //print("FARM \(flickrPhoto.farm)")
                    
                    flickrPhoto.server = photoDict.objectForKey("server") as! String
                    
                    flickrPhoto.secret = photoDict.objectForKey("secret") as! String
                    flickrPhoto.photoID = photoDict.objectForKey("id") as! String
                    
                    let searchURL:NSString = FlickrHelper.URLForFlickrPhoto(flickrPhoto, size: "m")
                    let phototitle: String = photoDict.objectForKey("title") as! String
                    
                    flickrPhotos[phototitle] = searchURL as String
                   // flickrPhotos = [phototitle: searchURL]
                    //flickrPhotos![phototitle] = searchURL
                    
                }
                completion(searchString: searchURL, flickrPhotos: flickrPhotos, error: nil)
                
                
            }
        }
    }
    
    
}

