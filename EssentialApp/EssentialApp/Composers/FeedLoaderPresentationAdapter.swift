//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 22/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate{
    private let feedLoader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader().sink { [weak self] completion in
            switch completion{
            case .failure(let err):
                self?.presenter?.didFinishedLoadingFeed(with: err)
            default: break
            }
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishedLoadingFeed(with: feed)
        }
    }
}
