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
        let items: [Item]
        
        var feed: [FeedItem]{ items.map(\.item) }
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
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result{
        guard response.statusCode == ok200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else{
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}
