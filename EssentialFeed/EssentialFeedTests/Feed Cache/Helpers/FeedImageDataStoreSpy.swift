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
    
    private var completions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private(set) var receivedMessages = [Message]()
    
    func retrieve(dataForURL url: URL, completion: @escaping(FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        completions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
    }
    
    func complete(with error: Error, at index: Int = 0){
        completions[index](.failure(error))
    }
    
    func complete(with data: Data?, at index: Int = 0){
        completions[index](.success(data))
    }
}
