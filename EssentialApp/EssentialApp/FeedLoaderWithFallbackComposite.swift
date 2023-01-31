//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Lorenzo Limoli on 31/01/23.
//

import Foundation
import EssentialFeed

public final class FeedLoaderWithFallbackComposite: FeedLoader{
    private let primaryLoader: FeedLoader
    private let fallbackLoader: FeedLoader
    
    public init(primaryLoader: FeedLoader, fallbackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load{ [weak self] result in
            switch result{
            case .success: completion(result)
            case .failure:
                self?.fallbackLoader.load(completion: completion)
            }
        }
    }
}
