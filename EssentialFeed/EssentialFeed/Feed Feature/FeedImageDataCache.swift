//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 13/02/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
