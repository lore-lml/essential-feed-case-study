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
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0){
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionCompletions[index](nil)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0){
        retrievalCompletions[index](error)
    }
    
    func completeWithEmptyCache(at index: Int = 0){
        retrievalCompletions[index](nil)
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
