//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 08/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader{
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public enum Error: Swift.Error{
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url){ [weak self] result in
            if self == nil { return }
            
            switch result{
            case .success((let data, let response)):
                let result = FeedItemsMapper.map(data, from: response)
                completion(result)
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    
}
