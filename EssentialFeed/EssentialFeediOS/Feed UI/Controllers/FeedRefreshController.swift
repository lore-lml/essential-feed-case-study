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
        viewModel.onChange = { [weak self] vm in
            if vm.isLoading{
                self?.view.beginRefreshing()
            }else{
                self?.view.endRefreshing()
            }
        }
        return view
    }
}
