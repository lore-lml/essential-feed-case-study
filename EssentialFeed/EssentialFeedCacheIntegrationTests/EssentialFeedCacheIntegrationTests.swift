//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Lorenzo Limoli on 02/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache(){
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load{ result in
            switch result{
            case .success(let imageFeed):
                XCTAssertEqual(imageFeed, [], "Expected empty feed")
                
            case .failure(let error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance(){
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "Wait for save completion")
        sutToPerformSave.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        let loadExp = expectation(description: "Wait for load completion")
        sutToPerformLoad.load { result in
            switch result{
            case .success(let imageFeed):
                XCTAssertEqual(imageFeed, feed)
                
            case .failure(let error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
    }
}

//MARK: Helpers
private extension EssentialFeedCacheIntegrationTests{
    private var testSpecificStoreURL: URL{ cachesDirectory.appendingPathComponent("\(type(of: self)).store") }
    
    private var cachesDirectory: URL{ FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!}
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader{
        
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        // The `null` device discards all data written to it, but reports that the write operation succeded. The writes are ignored, but CoreData still works with the in-memory object graph
        let storeURL = testSpecificStoreURL
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects(){
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
}
