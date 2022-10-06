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
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    private let client: HTTPClient
    
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
    
}

protocol HTTPClient{
    func get(from url: URL)
}

class HTTPCLientSpy: HTTPClient{
    var requestedURL: URL?
    
    func get(from url: URL){
        requestedURL = url
    }
}

final class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() throws {
        let client = HTTPCLientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPCLientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
