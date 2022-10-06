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
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
    
}

class HTTPClient{
    static let shared = HTTPClient()
    
    private init(){}
    
    var requestedURL: URL?
}

final class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() throws {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
