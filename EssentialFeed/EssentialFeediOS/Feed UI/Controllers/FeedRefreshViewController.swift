//
//  FeedRefreshViewController.swift.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 19/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit

protocol FeedRefreshViewControllerDelegate{
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView{
    private(set) lazy var view: UIRefreshControl = loadView()
    
    private let delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh(){
        delegate.didRequestFeedRefresh()
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
