//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 28/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CodableFeedStore{
    
    private struct Cache: Codable{
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage]{
            feed.map(\.local)
        }
    }
    
    private struct CodableFeedImage: Codable {
        
        private let id: UUID
        private let url: URL
        private let description: String?
        private let location: String?
        
        init(_ image: LocalFeedImage){
            self.id          = image.id
            self.url         = image.url
            self.description = image.description
            self.location    = image.location
        }
        
        var local: LocalFeedImage{
            LocalFeedImage(
                id          : id,
                url         : url,
                description : description,
                location    : location
            )
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion){
        guard let data = try? Data(contentsOf: storeURL) else{
            completion(.empty)
            return
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion){
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
        
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = makeSUT()
       
        expect(sut, toRetrieve: .empty)
    }

    
    func test_retrieve_hasNoSideEffectsOnEmptyCache(){
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundvaluesOnNonEmptyCache(){
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache(){
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
}


private extension CodableFeedStoreTests{
    
    private var testSpecificStoreURL: URL{ FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store") }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore{
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line){
        let exp = expectation(description: "Waiting for cache insertion")
        
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted succesfully", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult){
            case (.empty, .empty): break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line){
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
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
