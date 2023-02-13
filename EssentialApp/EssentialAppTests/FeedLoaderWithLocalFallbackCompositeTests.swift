//
//  FeedLoaderWithLocalFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Lorenzo Limoli on 25/01/23.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderWithLocalFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess(){
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(primaryFeed))
    }

    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure(){
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure(){
        let sut = makeSUT(primaryResult: .failure(anyNSError), fallbackResult: .failure(anyNSError))
        
        expect(sut, toCompleteWith: .failure(anyNSError))
    }
}


//MARK: Helpers
private extension FeedLoaderWithLocalFallbackCompositeTests{
    
    func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoader{
        let remoteLoader = FeedLoaderStub(result: primaryResult)
        let localLoader = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primaryLoader: remoteLoader, fallbackLoader: localLoader)
        trackForMemoryLeaks(remoteLoader)
        trackForMemoryLeaks(localLoader)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line){
        let exp = expectation(description: "Wait fo load completion")
        
        sut.load { receivedResult in
            
            switch (expectedResult, receivedResult){
            case let (.success(expectedFeed), .success(receivedFeed)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                
            case (.failure, .failure): break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
