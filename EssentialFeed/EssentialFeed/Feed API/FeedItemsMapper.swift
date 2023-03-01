//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 11/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

enum FeedItemsMapper{
    
    private struct Root: Decodable{
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem]{
        guard response.isOk, let root = try? JSONDecoder().decode(Root.self, from: data)
        else{
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
