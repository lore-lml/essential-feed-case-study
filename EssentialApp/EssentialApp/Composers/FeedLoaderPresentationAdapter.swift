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
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        cancellable = feedLoader().sink { [weak self] completion in
            switch completion{
            case .failure(let err):
                self?.presenter?.didFinishedLoading(with: err)
            default: break
            }
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishedLoading(with: feed)
        }
    }
}
