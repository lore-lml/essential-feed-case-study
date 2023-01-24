//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 24/01/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

final class FeedImageDataStoreSpy: FeedImageDataStore{
    
    enum Message: Equatable{
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }
    
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    private(set) var receivedMessages = [Message]()
    
    
}

extension FeedImageDataStoreSpy{
    func retrieve(dataForURL url: URL, completion: @escaping(FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func complete(with error: Error, at index: Int = 0){
        retrievalCompletions[index](.failure(error))
    }
    
    func complete(with data: Data?, at index: Int = 0){
        retrievalCompletions[index](.success(data))
    }
}

extension FeedImageDataStoreSpy{
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0){
        insertionCompletions[index](.failure(error))
    }
}
