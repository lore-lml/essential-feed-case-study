//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 25/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public final class LocalFeedLoader{
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

}

extension LocalFeedLoader: FeedCache{
    public typealias SaveResult = FeedCache.Result
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void){
        store.deleteCachedFeed{ [weak self] deletionResult in
            guard let self else { return }
            
            switch deletionResult{
            case .success:
                self.cache(feed, with: completion)
                
            case .failure(let deletionError):
                completion(.failure(deletionError))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void){
        self.store.insert(feed.toLocal(), timestamp: self.currentDate()){ [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        }
    }
}

extension LocalFeedLoader: FeedLoader{
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void){
        store.retrieve{ [weak self] result in
            guard let self else { return }
            
            switch result{
            case .failure(let error):
                completion(.failure(error))
                
            case .success(.some(let cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader{
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void){
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result{
            case .failure:
                self.store.deleteCachedFeed(completion: completion)
                
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: completion)
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension Array where Element == FeedImage{
    func toLocal() -> [LocalFeedImage]{
        map{ LocalFeedImage(
            id          : $0.id,
            url         : $0.url,
            description : $0.description,
            location    : $0.location
        )}
    }
}

private extension Array where Element == LocalFeedImage{
    func toModels() -> [FeedImage]{
        map{ FeedImage(
            id          : $0.id,
            url         : $0.url,
            description : $0.description,
            location    : $0.location
        )}
    }
}
