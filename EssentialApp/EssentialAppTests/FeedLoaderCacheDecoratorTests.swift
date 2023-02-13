//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Lorenzo Limoli on 13/02/23.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader{
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

    func test_load_deliversFeedOnLoaderSuccess(){
        let feed = uniqueFeed()
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailure(){
        let loader = FeedLoaderStub(result: .failure(anyNSError))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .failure(anyNSError))
    }
}


// MARK: HELPERS
private extension FeedLoaderCacheDecoratorTests{
    
    
}