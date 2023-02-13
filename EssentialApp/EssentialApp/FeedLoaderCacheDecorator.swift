//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Lorenzo Limoli on 13/02/23.
//

import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader{
    private let cache: FeedCache
    private let decoratee: FeedLoader
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load{ [weak self] result in
            completion(result.map{ feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

private extension FeedCache{
    func saveIgnoringResult(_ feed: [FeedImage]){
        save(feed) { _ in }
    }
}
