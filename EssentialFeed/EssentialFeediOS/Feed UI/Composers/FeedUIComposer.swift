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
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        let feedPresenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader), loadingView: WeakRefVirtualProxy(refreshController))
        
        presentationAdapter.presenter = feedPresenter
        
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
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map{ model in
            let viewModel = FeedImageViewModel<UIImage>(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}

private final class WeakRefVirtualProxy<T: AnyObject>{
    private weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate{
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result{
            case .success(let feed):
                self?.presenter?.didFinishedLoadingFeed(with: feed)
                
            case .failure(let err):
                self?.presenter?.didFinishedLoadingFeed(with: err)
            }
        }
    }
}
