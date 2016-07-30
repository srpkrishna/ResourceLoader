//
//  DownloadCancelTestCase.swift
//  test
//
//  Created by Phani on 30/07/16.
//  Copyright © 2016 phani. All rights reserved.
//

import XCTest

@testable import ImageLoaderDemo
class DownloadCancelTestCase:ResourceLoaderTests,UrlObserverDelegate {

    var countCancelled = 0 ;
    var countFinished = 0;
    
    var asyncExpectation:XCTestExpectation!
    var resourceManager:ResourceManager!
    
    override var name: String
        {
        get{
            return "DownloadCancelTestCase"
        }
    }
    
    override func setUp() {
        super.setUp()
        resourceManager = ResourceManager.init(configuration: nil);
        resourceManager.maxOperationsCount = 1;
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCancelDownload() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        asyncExpectation = expectationWithDescription("DownloadCancelTestCase")
        countFinished = 0;
        countCancelled = 0;
        
        for i in 0..<5
        {
            let rowKey = picturesWithNameAndUrl.allKeys[i] as! String
            
            let url = (picturesWithNameAndUrl.valueForKey(rowKey) as? String)!;
            
            XCTAssertNotNil(url, "url should not be nil")
            print("Download started for \(rowKey) = \(url)");
            //self.resourceManager.getDataFor(url, withIdentifier: "CellIdentifier",withUrlObserver: self);
            
            self.resourceManager.getDataFor(url, withIdentifier:"TestCase",withUrlObserver: self);
            self.resourceManager.cancelDataFor(url,withIdentifier:"TestCase");
        }
        
        
        self.waitForExpectationsWithTimeout(30) { error in
            
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
        
        countFinished += 1;
        
        if (errorMessage.containsString("cancelled"))
        {
            countCancelled += 1
        }
        
        print("countFinished  \(countFinished) countCancelled \(countCancelled)");
        
        if(countFinished == 5)
        {
            if( countCancelled > 1)
            {
                XCTAssert(true, "pass");
            }else
            {
                XCTFail("Atleast one should cancel")
            }
            
            print("test case passed");
            asyncExpectation.fulfill()
        }
        
        
    }

}
