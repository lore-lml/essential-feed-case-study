//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 25/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LocalFeedLoader{
    
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]){
        store.deleteCachedFeed()
    }
}

class FeedStore{
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeed(){
        deleteCachedFeedCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation(){
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion(){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
}

// MARK: Helpers
private extension CacheFeedUseCaseTests{
    
    var anyURL: URL{ .init(string: "http://any-url.com")! }
    
    func uniqueItem() -> FeedItem{
        .init(imageURL: anyURL, description: "any", location: "any")
    }
}