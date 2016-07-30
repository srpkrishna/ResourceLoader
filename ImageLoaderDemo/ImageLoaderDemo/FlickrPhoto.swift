//
//  FlickrPhoto.swift
//  test
//
//  Created by administrator on 27/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import Foundation
import UIKit

class FlickrPhoto: NSObject {
    
    var thumbnail:UIImage!
    var largeImage:UIImage!
    
    var photoID:String!
    var farm:Int!
    var server:String!
    var secret:String!
    
    override init() {
        super.init()
    }
    
}
