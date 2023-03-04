//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 04/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsPresenter{
    public static var title: String{
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the feed view"
        )
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel{
        .init(feed: feed)
    }
}
