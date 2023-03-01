//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 01/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

enum ImageCommentsMapper{
    
    private struct Root: Decodable{
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem]{
        guard response.isOk, let root = try? JSONDecoder().decode(Root.self, from: data)
        else{
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
}
