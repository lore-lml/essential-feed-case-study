//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 25/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore{
    typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias DeletionResult = Swift.Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
}
