//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 19/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ListViewController{
    var isShowingLoadingIndicator: Bool{ refreshControl?.isRefreshing == true }
    
    var errorMessage: String? { errorView.message }

    func simulateUserInitiatedReload(){
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateErrorViewTap(){
        errorView.simulateTap()
    }
}

extension ListViewController{
    var feedImagesSection: Int{ 0 }
    
    func numberOfRenderedFeedImageViews() -> Int{
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell?{
        guard numberOfRenderedFeedImageViews() > row else{
            return nil
        }
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func renderedFeedImageData(at index: Int) -> Data?{
        simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell?{
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
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
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell?{
        feedImageView(at: row) as? FeedImageCell
    }
    
    func simulateTapOnFeedImage(at row: Int){
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
}


extension ListViewController{
    var commentsSection: Int{ 0 }
    
    func numberOfRenderedComments() -> Int{
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }
    
    private func commentView(at row: Int) -> ImageCommentCell?{
        guard numberOfRenderedFeedImageViews() > row else{
            return nil
        }
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }

    
    func commentMessage(at row: Int) -> String?{
        commentView(at: row)?.messageLabel.text
    }
    
    func commentUsername(at row: Int) -> String?{
        commentView(at: row)?.usernameLabel.text
    }
    
    func commentDate(at row: Int) -> String?{
        commentView(at: row)?.dateLabel.text
    }
}
