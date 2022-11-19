//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 19/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public enum FeedUIComposer{
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController{
        
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map{ model in FeedImageCellController(model: model, imageLoader: imageLoader)}
        }
        
        return feedController
    }
}
