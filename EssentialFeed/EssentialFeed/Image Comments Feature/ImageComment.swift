//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 01/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Equatable{
    public let id: UUID
    public let message: String
    public let createdAt: Date
    public let username: String
    
    public init(id: UUID, message: String, createdAt: Date, username: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.username = username
    }
}
