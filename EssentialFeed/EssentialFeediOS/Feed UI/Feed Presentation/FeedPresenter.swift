//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 21/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel{
    let isLoading: Bool
}

protocol FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel{
    let feed: [FeedImage]
}

protocol FeedView{
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter{
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func didStartLoadingFeed(){
        loadingView?.display(.init(isLoading: true))
    }
    
    func didFinishedLoadingFeed(with feed: [FeedImage]){
        feedView?.display(.init(feed: feed))
        loadingView?.display(.init(isLoading: false))
    }
    
    func didFinishedLoadingFeed(with error: Error?){
        loadingView?.display(.init(isLoading: false))
    }
}
