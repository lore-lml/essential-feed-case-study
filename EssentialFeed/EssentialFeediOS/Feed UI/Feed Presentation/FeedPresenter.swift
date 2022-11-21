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
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView{
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter{
    
    let feedView: FeedView
    let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    static var title: String{
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view"
        )
    }
    
    func didStartLoadingFeed(){
        loadingView.display(.init(isLoading: true))
    }
    
    func didFinishedLoadingFeed(with feed: [FeedImage]){
        feedView.display(.init(feed: feed))
        loadingView.display(.init(isLoading: false))
    }
    
    func didFinishedLoadingFeed(with error: Error?){
        loadingView.display(.init(isLoading: false))
    }
}
