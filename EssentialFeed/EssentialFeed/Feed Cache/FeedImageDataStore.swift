//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 24/01/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageDataStore{
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
