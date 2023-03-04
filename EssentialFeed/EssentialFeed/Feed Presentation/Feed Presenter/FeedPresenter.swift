//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 15/12/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public final class FeedPresenter{
    public static var title: String{
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view"
        )
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel{
        .init(feed: feed)
    }
}
