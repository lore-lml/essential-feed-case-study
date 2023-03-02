//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 11/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public enum FeedItemsMapper{
    
    private struct Root: Decodable{
        private let items: [RemoteFeedItem]
        
        private struct RemoteFeedItem: Decodable {
            let id: UUID
            let image: URL
            let description: String?
            let location: String?
        }
        
        var feed: [FeedImage] {
            items.map{ FeedImage(
                id          : $0.id,
                url         : $0.image,
                description : $0.description,
                location    : $0.location
            )}
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage]{
        guard response.isOk, let root = try? JSONDecoder().decode(Root.self, from: data)
        else{
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.feed
    }
}
