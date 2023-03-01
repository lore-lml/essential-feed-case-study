//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 01/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteLoader<Resource>{
    
    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.client = client
        self.url = url
        self.mapper = mapper
    }
    
    public enum Error: Swift.Error{
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<Resource, Swift.Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    
    private let url: URL
    private let client: HTTPClient
    private let mapper: Mapper
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url){ [weak self] result in
            guard let self else { return }
            
            switch result{
            case .success((let data, let response)):
                completion(self.map(data, from: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result{
        do{
            let items = try mapper(data, response)
            return .success(items)
            
        }catch{
            return.failure(Error.invalidData)
        }
    }
}


