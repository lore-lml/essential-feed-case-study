//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 25/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteFeedItem: Decodable {
    
    let id: UUID
    let image: URL
    let description: String?
    let location: String?

}
