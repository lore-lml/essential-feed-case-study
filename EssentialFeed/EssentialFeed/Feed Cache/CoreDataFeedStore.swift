//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 31/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public final class CoreDataFeedStore: FeedStore{
    
    public init(){}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
