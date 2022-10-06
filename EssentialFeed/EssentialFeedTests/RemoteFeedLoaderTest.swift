//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 06/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader{
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
    
}

class HTTPClient{
    static var shared = HTTPClient()
    
    func get(from url: URL){}
}

class HTTPCLientSpy: HTTPClient{
    var requestedURL: URL?
    
    override func get(from url: URL){
        requestedURL = url
        super.get(from: url)
    }
}

final class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() throws {
        let client = HTTPCLientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPCLientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
