//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 04/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public final class LoadResourcePresenter{
    public typealias Mapper = (String) -> String
    
    private let resourceView: ResourceView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let mapper: Mapper
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
             tableName: "Feed",
             bundle: Bundle(for: FeedPresenter.self),
             comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(resourceView: ResourceView, loadingView: FeedLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper){
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading(){
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
    }
    
    public func didFinishedLoading(with resource: String){
        resourceView.display(mapper(resource))
        loadingView.display(.init(isLoading: false))
    }
    
    public func didFinishedLoadingFeed(with error: Error?){
        errorView.display(.error(message: feedLoadError))
        loadingView.display(.init(isLoading: false))
    }
}
