//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Lorenzo Limoli on 14/03/23.
//

import Foundation


import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

enum CommentsUIComposer{
    static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>
    ) -> ListViewController{

        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: { commentsLoader().dispatchOnMainQueue() })
        
        let feedController = ListViewController.makeWith(
            title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }
            ),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map(_:)
        )
        
        return feedController
    }
}

private extension ListViewController{
    static func makeWith(title: String) -> ListViewController{
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}

