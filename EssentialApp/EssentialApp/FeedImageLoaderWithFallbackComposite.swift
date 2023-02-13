//
//  FeedImageLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Lorenzo Limoli on 31/01/23.
//

import Foundation
import EssentialFeed

public final class FeedImageLoaderWithFallbackComposite: FeedImageDataLoader{
    
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
    
    private final class TaskWrapper: FeedImageDataLoaderTask{
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        let taskWrapper = TaskWrapper()
        taskWrapper.wrapped = primaryLoader.loadImageData(from: url) { [weak self] result in
            
            switch result{
            case .success: completion(result)
            case .failure:
                taskWrapper.wrapped = self?.fallbackLoader.loadImageData(from: url, completion: completion)
                
            }
        }
        return taskWrapper
    }
}
