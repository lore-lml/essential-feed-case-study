//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 26/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage{
    .init(url: anyURL, description: "any", location: "any")
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]){
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map{ LocalFeedImage(id: $0.id, url: $0.url, description: $0.description, location: $0.location) }
    return (models, local)
}

extension Date{
    func minusFeedCacheMaxAge() -> Date{
        return adding(days: -7)
    }
    
    func adding(days: Int) -> Date{
        return Calendar(identifier: .gregorian)
            .date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date{
        return self + seconds
    }
}
