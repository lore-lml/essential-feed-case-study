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
        
        let exp = expectation(description: "Wait fo load completion")
        sut.load { result in
            switch result{
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
                
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure(){
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Wait fo load completion")
        sut.load { result in
            switch result{
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, fallbackFeed)
                
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
