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
        
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedViewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        
        return feedController
    }
    
    // [FeedImage] -> Adapt -> [FeedImageCellController]
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void{
        return { [weak controller] feed in
            controller?.tableModel = feed.map{ model in
                let viewModel = FeedImageViewModel<UIImage>(model: model, imageLoader: loader, imageTransformer: UIImage.init)
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}
