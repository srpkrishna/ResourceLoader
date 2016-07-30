//
//  CacheTestCase.swift
//  test
//
//  Created by Phani on 30/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import XCTest

@testable import ImageLoaderDemo
class CacheTestCase:ResourceLoaderTests,UrlObserverDelegate {

    var countDowloaded = 0;
    var asyncExpectation:XCTestExpectation!
    var resourceManager:ResourceManager!
    
    override var name: String
        {
        get{
            return "CacheTestCase"
        }
    }
    
    override func setUp() {
        super.setUp()
        
        resourceManager = ResourceManager.init(configuration: nil);
        resourceManager.cacheResourcesCount = 4;
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        //continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        //XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func downloads(startIndex:Int, _ endIndex:Int, _ name:String) {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        asyncExpectation = expectationWithDescription("CacheTestCase"+name)
        countDowloaded = endIndex - startIndex;
        
        for i in startIndex...endIndex
        {
            let rowKey = picturesWithNameAndUrl.allKeys[i] as! String
            
            let url = (picturesWithNameAndUrl.valueForKey(rowKey) as? String)!;
            
            XCTAssertNotNil(url, "url should not be nil")
            print("Download started for \(rowKey) = \(url)");
            //self.resourceManager.getDataFor(url, withIdentifier: "CellIdentifier",withUrlObserver: self);
            
            self.resourceManager.getDataFor(url, withIdentifier:"TESTCACHE",withUrlObserver: self);
            
        }
        
        self.waitForExpectationsWithTimeout(100) { error in
            
            if(error != nil )
            {
                XCTFail("Taking too much time to download");
                
            }else
            {
                XCTAssert(true);
            }
            
        }
        
        
        
    }
    
    func didFetchUrlData(urlString:String, data:NSData?, errorMessage:String)
    {
        countDowloaded -= 1;
        if(countDowloaded < 0)
        {
            
            asyncExpectation.fulfill()
        }
        
        
    }
    
    func testCacheElements()
    {
        downloads(0,4,"testCacheElements");
        for i in 0..<5
        {
            let rowKey = picturesWithNameAndUrl.allKeys[i] as! String
            
            let url = (picturesWithNameAndUrl.valueForKey(rowKey) as? String)!;
            
            XCTAssertNotNil(url, "url should not be nil")
            let data = resourceManager.getDataFromCache(url);
            
            print("Data length loaded from cache for \(rowKey) with url \(url) is \(data?.length) ")
            if(data?.length < 1 && url != "NO URL")
            {
                XCTFail("data not found in Cache ideally it should be in \(rowKey) ");
                
            }else if (url == "NO URL" && data?.length > 0)
            {
                XCTFail("data found in for failed operation \(rowKey) ");
            }
            
        }
        
        XCTAssert(true);
    }
    
    func testLRUCache()
    {
        resourceManager.maxOperationsCount = 1;

        downloads(0,5,"testLRUCache");
        
        //since max cacheSize = 4;
        //last recent cache order should be 5,3,2,1 (as one will fail)
        //so element with index 0 shouldnt be cache
        
        let rowKey = picturesWithNameAndUrl.allKeys[0] as! String
        
        let url = (picturesWithNameAndUrl.valueForKey(rowKey) as? String)!;
        
        XCTAssertNotNil(url, "url should not be nil")
        let data = resourceManager.getDataFromCache(url);
        
        print("Data length loaded from cache for \(rowKey) with url \(url) is \(data?.length) ")
        if(data?.length > 0)
        {
            XCTFail("data not found in Cache ideally it should be in \(rowKey) ");
            
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
