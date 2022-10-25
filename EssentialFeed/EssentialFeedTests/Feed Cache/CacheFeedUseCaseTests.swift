//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 25/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest

class LocalFeedLoader{
    init(store: FeedStore) {
        self.store = store
    }
    
    let store: FeedStore
}

class FeedStore{
    var deleteCachedFeedCallCount = 0
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation(){
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}
