//
//  FeedRefreshController.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 19/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView{
    private(set) lazy var view: UIRefreshControl = loadView()
    
    private let feedPresenter: FeedPresenter
    
    init(feedPresenter: FeedPresenter) {
        self.feedPresenter = feedPresenter
    }
    
    @objc func refresh(){
        feedPresenter.loadFeed()
    }
    
    private func loadView() -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        let action = viewModel.isLoading ? view.beginRefreshing : view.endRefreshing
        action()
    }
}
