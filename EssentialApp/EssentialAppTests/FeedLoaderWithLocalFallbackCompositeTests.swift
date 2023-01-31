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
        primaryLoader.load(completion: completion)
    }
}

final class FeedLoaderWithLocalFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess(){
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let remoteLoader = LoaderStub(result: .success(primaryFeed))
        let localLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primaryLoader: remoteLoader, fallbackLoader: localLoader)
        
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

    
}

private extension FeedLoaderWithLocalFallbackCompositeTests{
    
    func uniqueFeed() -> [FeedImage]{
        return [
            FeedImage(url: .init(string: "http://any-url.com")!, description: "any", location: "any")
        ]
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
