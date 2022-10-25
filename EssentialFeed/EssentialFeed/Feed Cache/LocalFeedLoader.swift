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
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void){
        store.deleteCachedFeed{ [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
                return
            }
            self.cache(items, with: completion)
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void){
        self.store.insert(items.toLocal(), timestamp: self.currentDate()){ [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        }
    }
}

private extension Array where Element == FeedItem{
    func toLocal() -> [LocalFeedItem]{
        map{ LocalFeedItem(
            id          : $0.id,
            imageURL    : $0.imageURL,
            description : $0.description,
            location    : $0.location
        )}
    }
}
