//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 22/12/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedImageDataLoader {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error{
        case invalidData
    }

    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .failure(error): task.complete(with: .failure(error))
            case let .success((data, response)):
                guard !data.isEmpty, response.statusCode == 200 else{
                    return task.complete(with: .failure(Error.invalidData))
                }
                task.complete(with: .success(data))
            }
        }
        return task
    }
}
