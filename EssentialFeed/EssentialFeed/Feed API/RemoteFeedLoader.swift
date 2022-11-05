//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 08/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader{
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public enum Error: Swift.Error{
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    private let url: URL
    private let client: HTTPClient
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url){ [weak self] result in
            if self == nil { return }
            
            switch result{
            case .success((let data, let response)):
                completion(Self.map(data, from: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result{
        do{
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
            
        }catch{
            return.failure(error)
        }
    }
}


private extension Array where Element == RemoteFeedItem{
    func toModels() -> [FeedImage]{
        map{ FeedImage(
            id          : $0.id,
            url    : $0.image,
            description : $0.description,
            location    : $0.location
        )}
    }
}
