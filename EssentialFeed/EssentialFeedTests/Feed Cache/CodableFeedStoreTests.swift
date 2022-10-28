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
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion){
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = CodableFeedStore()
        let exp = expectation(description: "Waiting for cache retrieval")
        
        sut.retrieve { result in
            switch result{
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    
    func test_retrieve_hasNoSideEffectsOnEmptyCache(){
        let sut = CodableFeedStore()
        let exp = expectation(description: "Waiting for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult){
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty results, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
