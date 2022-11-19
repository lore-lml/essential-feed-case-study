//
//  FeedRefreshController.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 19/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit

final class FeedRefreshViewController: NSObject{
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    
    private let viewModel: FeedViewModel
    
    init(feedViewModel: FeedViewModel) {
        self.viewModel = feedViewModel
    }
    
    @objc func refresh(){
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl{
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading{
                view?.beginRefreshing()
            }else{
                view?.endRefreshing()
            }
        }
        return view
    }
}
