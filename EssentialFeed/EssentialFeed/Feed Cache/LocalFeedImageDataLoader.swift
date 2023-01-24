//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 24/01/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader{
    
    private class Task: FeedImageDataLoaderTask{
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result){
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions(){
            completion = nil
        }
    }
    
    public enum Error: Swift.Error{
        case failed
        case notFound
    }
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore){
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url){ [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError{ _ in Error.failed }
                .flatMap{ data in
                    guard let data else{
                        return .failure(Error.notFound)
                    }
                    
                    return .success(data)
                })
        }
        return task
    }
}
