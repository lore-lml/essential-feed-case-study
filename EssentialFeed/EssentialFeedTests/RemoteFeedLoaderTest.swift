//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 06/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() throws {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice(){
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load{ _ in }
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load{ capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy){
        let client = HTTPCLientSpy()
        return (sut: RemoteFeedLoader(url: url, client: client), client: client)
    }
    
    private class HTTPCLientSpy: HTTPClient{
        
        
        private var messages = [(url: URL, completion: (Error) -> Void)]()
        
        var requestedURLs: [URL]{
            messages.map(\.url)
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void){
            messages.append((url, completion))
        }
        
        func complete(with clientError: Error, at index: Int = 0){
            messages[index].completion(clientError)
        }
    }
}
