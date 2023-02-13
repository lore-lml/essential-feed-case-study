//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Lorenzo Limoli on 13/02/23.
//

import Foundation
import EssentialFeed

final class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
