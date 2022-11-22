//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 22/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import EssentialFeed

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate{
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
