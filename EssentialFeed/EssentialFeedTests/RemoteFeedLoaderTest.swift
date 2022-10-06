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

final class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() throws {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }

    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy){
        let client = HTTPCLientSpy()
        return (sut: RemoteFeedLoader(url: url, client: client), client: client)
    }
    
    private class HTTPCLientSpy: HTTPClient{
        var requestedURL: URL?
        
        func get(from url: URL){
            requestedURL = url
        }
    }
}
