//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 21/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView{
    func display(isLoading: Bool)
}

protocol FeedView{
    func display(feed: [FeedImage])
}

final class FeedPresenter{
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed(){
        loadingView?.display(isLoading: true)
        feedLoader.load{ [weak self] result in
            if let feed = try? result.get(){
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
