//
//  RemoteLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 01/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class RemoteLoaderTests: XCTestCase {

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
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach{ index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems(){
        let (sut, client) = makeSUT()
        
        let (item1, item1JSON) = makeItem(imageURL: URL(string: "http://a-url.com")!)
        
        let (item2, item2JSON) = makeItem(description: "a description", location: "a location", imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1, item2]
        let itemsJson = [item1JSON, item2JSON]
        
        expect(sut, toCompleteWithResult: .success(items)) {
            let json = makeItemsJSON(itemsJson)
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfeterSUTInstanceHasBeenDeallocated(){
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader? = .init(url: url, client: client)
        
        var capturedResults = [RemoteLoader.Result]()
        sut?.load{ capturedResults.append($0) }
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
}


private extension RemoteLoaderTests{
    // MARK: Helpers
    func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteLoader, client: HTTPClientSpy){
        
        let client = HTTPClientSpy()
        let sut = RemoteLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut: sut, client: client)
    }
    
    private func makeItem(id: UUID = .init(), description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]){
        
        let model = FeedImage(id: id, url: imageURL, description: description, location: location)
        
        let json = [
            "id": model.id.uuidString,
            "image": model.url.absoluteString,
            "description": model.description,
            "location": model.location
        ]
            .compactMapValues{ $0 }
        
        return (model, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data{
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    func expect(_ sut: RemoteLoader, toCompleteWithResult expectedResult: RemoteLoader.Result, when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load{ receivedResult in
            switch (receivedResult, expectedResult){
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            
            case let (.failure(receivedErr as RemoteLoader.Error), .failure(expectedErr as RemoteLoader.Error)):
                XCTAssertEqual(receivedErr, expectedErr, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func failure(_ error: RemoteLoader.Error) -> RemoteLoader.Result{ .failure(error) }
    
}