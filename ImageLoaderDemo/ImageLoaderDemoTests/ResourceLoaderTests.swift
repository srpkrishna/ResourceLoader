//
//  ResourceLoaderTests.swift
//  test
//
//  Created by Phani on 30/07/16.
//  Copyright © 2016 phani. All rights reserved.
//


import XCTest
@testable import ImageLoaderDemo

class ResourceLoaderTests: XCTestCase {
    var picturesWithNameAndUrl:NSDictionary!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
        picturesWithNameAndUrl = getPhotos();
        
        print("________________");
        print("test case started for \(self.name)")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        print("test case ended for \(self.name)")
        print("________________");
        print(" ");
    }
    
     func getPhotos() -> NSDictionary{
        
        let pictures = NSDictionary.init(contentsOfURL:NSURL.init(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")!);
        return pictures!;
        
     }
    

}