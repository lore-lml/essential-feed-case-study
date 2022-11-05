//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 26/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore{

    enum ReceivedMessage: Equatable{
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion){
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0){
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](.success(()))
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0){
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionCompletions[index](.success(()))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0){
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with images: [LocalFeedImage], timestamp: Date, at index: Int = 0){
        
        retrievalCompletions[index](.found(feed: images, timestamp: timestamp))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0){
        retrievalCompletions[index](.empty)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion){
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion){
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
}
