//
//  LoadResourcePresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 22/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class LoadResourcePresentationAdapter<Resource, View: ResourceView>{
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<Resource, View>?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader().sink { [weak self] completion in
            switch completion{
            case .failure(let err):
                self?.presenter?.didFinishedLoading(with: err)
            default: break
            }
        } receiveValue: { [weak self] resource in
            self?.presenter?.didFinishedLoading(with: resource)
        }
    }
}

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate{
    func didRequestFeedRefresh(){
        loadResource()
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate{
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
