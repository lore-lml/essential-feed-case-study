//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 15/12/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedView{
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter{
    private let feedView: FeedView
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    
    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
             tableName: "Shared",
             bundle: Bundle(for: FeedPresenter.self),
             comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public static var title: String{
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view"
        )
    }
    
    public init(feedView: FeedView, loadingView: ResourceLoadingView, errorView: ResourceErrorView){
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
