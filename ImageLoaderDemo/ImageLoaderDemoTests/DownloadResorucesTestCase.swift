//
//  DownloadResorucesTestCase.swift
//  test
//
//  Created by Phani on 30/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import XCTest

@testable import ImageLoaderDemo
class DownloadResorucesTestCase: ResourceLoaderTests,UrlObserverDelegate {
    
    var countDowloaded = 0;
    var countFailed = 0;
    var asyncExpectation:XCTestExpectation!
    var resourceManager:ResourceManager!
    
    override var name: String
    {
        get{
            return "DownloadResorucesTestCase"
        }
    }
    
    override func setUp() {
        super.setUp()
       
        resourceManager = ResourceManager.init(configuration: nil);
        resourceManager.maxOperationsCount = 2;
        
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

    func testDownloads() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        asyncExpectation = expectationWithDescription("DownloadResorucesTestCase")
        countDowloaded = 0;
        countFailed = 0;
        
        for i in 0..<5
        {
            let rowKey = picturesWithNameAndUrl.allKeys[i] as! String
            
            let url = (picturesWithNameAndUrl.valueForKey(rowKey) as? String)!;
            
            XCTAssertNotNil(url, "url should not be nil")
            print("Download started for \(rowKey) = \(url)");
            //self.resourceManager.getDataFor(url, withIdentifier: "CellIdentifier",withUrlObserver: self);
            
           self.resourceManager.getDataFor(url, withIdentifier:"TESTCASE",withUrlObserver: self);
            
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
        print("Download ended for \(urlString) with data length \(data?.length) with error \(errorMessage) ");
        if data?.length > 0
        {
            countDowloaded += 1
  
        }else
        {
            countFailed += 1

        }
        
        print("countDowloaded  \(countDowloaded) countFalied \(countFailed)");
        
        if(countDowloaded+countFailed == 5)
        {
            if( countDowloaded == 4 && countFailed == 1)
            {
                XCTAssert(true, "pass");
            }else
            {
                XCTFail("One download should fail, everything else should pass. Some problem with input source urls or ResourceManager")
            }
            
            print("test case passed");
            asyncExpectation.fulfill()
        }
        
        
    }

}
