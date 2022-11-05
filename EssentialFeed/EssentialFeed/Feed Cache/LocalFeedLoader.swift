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

extension LocalFeedLoader{
    public typealias SaveResult = Error?
    
    public func save(_ feed: [FeedImage], completion: @escaping (Error?) -> Void){
        store.deleteCachedFeed{ [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
                return
            }
            self.cache(feed, with: completion)
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (Error?) -> Void){
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
                
            case .success(.found(let feed, let timestamp)) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toModels()))
                
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader{
    public func validateCache(){
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result{
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case let .success(.found(_, timestamp)) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed{ _ in }
                
            case .success: break
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
