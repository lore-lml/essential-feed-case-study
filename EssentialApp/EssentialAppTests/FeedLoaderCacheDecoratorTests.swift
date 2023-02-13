//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Lorenzo Limoli on 13/02/23.
//

import XCTest
import EssentialFeed

protocol FeedCache{
    typealias Result = Swift.Result<Void, Error>
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader{
    private let cache: FeedCache
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load{ [weak self] result in
            completion(result.map{ feed in
                self?.cache.save(feed){ _  in }
                return feed
            })
        }
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

    func test_load_deliversFeedOnLoaderSuccess(){
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailure(){
        let sut = makeSUT(loaderResult: .failure(anyNSError))
        
        expect(sut, toCompleteWith: .failure(anyNSError))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess(){
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    func test_load_doesNotCacheOnLoaderFailure(){
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [], "Expected not to cache loaded feed on load error")
    }
}


// MARK: HELPERS
private extension FeedLoaderCacheDecoratorTests{
    
    func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> FeedLoader{
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    final class CacheSpy: FeedCache{
        private(set) var messages = [Message]()
        
        enum Message: Equatable{
            case save([FeedImage])
        }
        
        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
