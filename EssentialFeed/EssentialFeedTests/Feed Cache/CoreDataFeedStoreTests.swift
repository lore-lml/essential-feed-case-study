//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 31/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//


import XCTest
import EssentialFeed

final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStore {
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = makeSUT()
       
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    
    func test_retrieve_hasNoSideEffectsOnEmptyCache(){
        let sut = makeSUT()
       
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache(){
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache(){
        
    }
    
    func test_retrieve_deliversFailureOnRetrievalError(){
        
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure(){
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache(){
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache(){
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues(){
        
    }
    
    func test_insert_deliversErrorOnInsertionError(){
        
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError(){
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache(){
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache(){
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache(){
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_delete_deliversErrorOnDeletionError(){
        
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError(){
        
    }
    
    func test_storeSideEffects_runSerially(){
        
    }
}

private extension CoreDataFeedStoreTests{
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore{
        
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut)
        return sut
    }
}
