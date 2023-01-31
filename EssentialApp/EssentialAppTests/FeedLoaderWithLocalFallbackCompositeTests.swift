//
//  FeedLoaderWithLocalFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Lorenzo Limoli on 25/01/23.
//

import XCTest
import EssentialFeed

final class FeedLoaderWithFallbackComposite: FeedLoader{
    private let primaryLoader: FeedLoader
    private let fallbackLoader: FeedLoader
    
    init(primaryLoader: FeedLoader, fallbackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load{ [weak self] result in
            switch result{
            case .success: completion(result)
            case .failure:
                self?.fallbackLoader.load(completion: completion)
            }
        }
    }
}

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
        let remoteLoader = LoaderStub(result: primaryResult)
        let localLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primaryLoader: remoteLoader, fallbackLoader: localLoader)
        trackForMemoryLeaks(remoteLoader)
        trackForMemoryLeaks(localLoader)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    func uniqueFeed() -> [FeedImage]{
        return [
            FeedImage(url: .init(string: "http://any-url.com")!, description: "any", location: "any")
        ]
    }
    
    var anyNSError: NSError{ .init(domain: "Any error", code: -1) }
    
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
    
    final class LoaderStub: FeedLoader{
        
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
