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
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
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
    
    public func load(completion: @escaping (LoadResult) -> Void){
        store.retrieve{ [weak self] result in
            guard let self else { return }
            
            switch result{
            case .failure(let error):
                completion(.failure(error))
                
            case .found(let feed, let timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
    
    public func validateCache(){
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result{
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case let .found(_, timestamp) where !self.validate(timestamp):
                self.store.deleteCachedFeed{ _ in }
                
            case .empty, .found: break
            }
        }
        
    }
    
    private var maxCacheAgeInDays: Int{ 7 }
    
    private func validate(_ timestamp: Date) -> Bool{
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else{
            return false
        }
        
        return currentDate() < maxCacheAge
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (Error?) -> Void){
        self.store.insert(feed.toLocal(), timestamp: self.currentDate()){ [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
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
