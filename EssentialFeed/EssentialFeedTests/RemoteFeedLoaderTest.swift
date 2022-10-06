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
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    private let client: HTTPClient
    private let url: URL
    
    func load() {
        client.get(from: url)
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
        let url = URL(string: "https://a-url.com")!
        let client = HTTPCLientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let url = URL(string: "https://a-url.com")!
        let client = HTTPCLientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }

}
