//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 26/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
final class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init(){
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval(){
        let (sut, store) = makeSUT()
        
        sut.load(){ _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError(){
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError
        
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeWithEmptyCache()
        }
    }
}


// MARK: Helpers
extension LoadFeedFromCacheUseCaseTests{
    
    private var anyNSError: NSError{ .init(domain: "any error", code: 1) }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Waiting for load completion")

        sut.load{ receivedResult in
            
            switch (receivedResult, expectedResult){
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                
            case let (.failure(receivedErorr as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedErorr, expectedError, file: file, line: line)
             
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}
