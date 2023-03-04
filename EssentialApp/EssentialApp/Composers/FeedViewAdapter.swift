//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 22/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView{
    typealias ResourceViewModel = FeedViewModel
    
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ resourceViewModel: ResourceViewModel) {
        controller?.display(resourceViewModel.feed.map{ model in
            
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>> { [imageLoader] in
                imageLoader(model.url)
            }
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter<FeedImageCellController, UIImage>.map(model),
                delegate: adapter
            )
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.init(data:)
            )
            
            return view
        })
    }
}
