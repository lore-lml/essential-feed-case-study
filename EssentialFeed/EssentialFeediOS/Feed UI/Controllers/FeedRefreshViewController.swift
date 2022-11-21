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
    @IBOutlet private var view: UIRefreshControl?
    
    var delegate: FeedRefreshViewControllerDelegate?
    
    @IBAction func refresh(){
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        let action = viewModel.isLoading ? view?.beginRefreshing : view?.endRefreshing
        action?()
    }
}
