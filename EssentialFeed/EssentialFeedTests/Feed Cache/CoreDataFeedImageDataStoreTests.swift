//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 25/01/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {

    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {

    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }

}

final class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL)
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let nonMatchingURL = URL(string: "http://another-url.com")!
        
        insert(anyData, for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }
}

// - MARK: Helpers
private extension CoreDataFeedImageDataStoreTests{
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    func localImage(url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), url: url, description: "any", location: "any")
    }

    func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line){
        let exp = expectation(description: "Waiting for cache insertion")
        let image = localImage(url: url)
        
        sut.insert([image], timestamp: Date()) { result in
            
            switch result{
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                
            case .success:
                sut.insert(data, for: url) { result in
                    if case let .failure(error) = result{
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                }
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
