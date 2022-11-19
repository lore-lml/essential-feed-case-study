//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 19/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedViewController{
    var isShowingLoadingIndicator: Bool{ refreshControl?.isRefreshing == true }
    
    var feedImagesSection: Int{ 0 }
    
    func simulateUserInitiatedFeedReload(){
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell?{
        feedImageView(at: row) as? FeedImageCell
    }
    
    func simulateFeedImageViewNotVisible(at row: Int){
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    func simulateFeedImageViewNearVisible(at row: Int){
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: 0)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int){
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func numberOfRenderedFeedImageViews() -> Int{
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell?{
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}
