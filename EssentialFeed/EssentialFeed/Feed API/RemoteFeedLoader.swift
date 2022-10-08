//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 08/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public enum HTTPClientResult{
    case success(HTTPURLResponse)
    case failure(Error)
}

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
    
    private let url: URL
    private let client: HTTPClient
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url){ result in
            
            switch result{
            case .success:
                completion(.invalidData)
                
            case .failure:
                completion(.connectivity)
            }
        }
    }
    
}


