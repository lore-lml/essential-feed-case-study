//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 24/01/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader{
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore){
        self.store = store
    }
}

// MARK: LOAD USE CASE
public extension LocalFeedImageDataLoader{
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
    
    enum LoadError: Swift.Error{
        case failed
        case notFound
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url){ [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError{ _ in LoadError.failed }
                .flatMap{ data in
                    guard let data else{
                        return .failure(LoadError.notFound)
                    }
                    
                    return .success(data)
                })
        }
        return task
    }
}

// MARK: SAVE USE CASE
extension LocalFeedImageDataLoader: FeedImageDataCache{
    public typealias SaveResult = Result<Void, Swift.Error>
    
    public enum SaveError: Swift.Error{
        case failed
    }
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            completion(result.mapError{ _ in SaveError.failed })
        }
    }
}
