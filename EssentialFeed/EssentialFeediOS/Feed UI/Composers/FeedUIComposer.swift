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
        
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedPresenter: feedPresenter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        feedPresenter.loadingView = refreshController
        feedPresenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
        
        return feedController
    }
    
    
}

private final class FeedViewAdapter: FeedView{
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map{ model in
            let viewModel = FeedImageViewModel<UIImage>(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}
