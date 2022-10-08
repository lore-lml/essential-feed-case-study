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
        
        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach{ index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data(bytes: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
}


private extension RemoteFeedLoaderTest{
    // MARK: Helpers
    func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy){
        let client = HTTPCLientSpy()
        return (sut: RemoteFeedLoader(url: url, client: client), client: client)
    }
    
    func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        sut.load{ capturedErrors.append($0) }
        
        action()
        
        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
    }
    
    class HTTPCLientSpy: HTTPClient{
        
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL]{
            messages.map(\.url)
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
            messages.append((url, completion))
        }
        
        func complete(with clientError: Error, at index: Int = 0){
            messages[index].completion(.failure(clientError))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0){
            let url = messages[index].url
            let response = HTTPURLResponse(
                url:            url,
                statusCode:     code,
                httpVersion:    nil,
                headerFields:   nil
            )!
            
            messages[index].completion(.success((data, response)))
        }
    }
}
