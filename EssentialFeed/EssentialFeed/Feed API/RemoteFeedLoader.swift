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
            case .success((let data, let response)):
                do{
                    let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items))
                    
                }catch let err as Error{
                    completion(.failure(err))
                }catch{
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private enum FeedItemsMapper{
    
    private struct Root: Decodable{
        let items: [Item]
    }

    private struct Item: Decodable {
        
        let id: UUID
        let image: URL
        let description: String?
        let location: String?
        
        var item: FeedItem{
            return FeedItem(
                id: id,
                imageURL: image,
                description: description,
                location: location
            )
        }
    }
    
    private static let ok200 = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem]{
        guard response.statusCode == ok200 else{
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return try JSONDecoder().decode(Root.self, from: data).items.map(\.item)
    }
}
