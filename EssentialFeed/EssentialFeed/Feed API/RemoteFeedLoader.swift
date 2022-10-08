//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 08/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader{
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public enum Error: Swift.Error{
        case connectivity
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public func load(completion: @escaping (Error) -> Void = { _ in }) {
        client.get(from: url){ error in
            completion(.connectivity)
        }
    }
    
}


