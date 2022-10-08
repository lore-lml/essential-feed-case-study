//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 08/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public typealias HTTPClientSuccessResult = (Data, HTTPURLResponse)

public typealias HTTPClientResult = Result<HTTPClientSuccessResult, Error>

public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

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
        client.get(from: url){ result in
            
            switch result{
            case .success((let data, _)):
                if let _ = try? JSONSerialization.jsonObject(with: data){
                    completion(.success([]))
                }else{
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
}


