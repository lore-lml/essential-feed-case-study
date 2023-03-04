//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 04/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public final class LoadResourcePresenter{
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
             tableName: "Feed",
             bundle: Bundle(for: FeedPresenter.self),
             comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView){
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
    }
    
    public func didFinishedLoadingFeed(with feed: [FeedImage]){
        feedView.display(.init(feed: feed))
        loadingView.display(.init(isLoading: false))
    }
    
    public func didFinishedLoadingFeed(with error: Error?){
        errorView.display(.error(message: feedLoadError))
        loadingView.display(.init(isLoading: false))
    }
}
