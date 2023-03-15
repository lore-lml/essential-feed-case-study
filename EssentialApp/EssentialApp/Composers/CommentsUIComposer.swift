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
    
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
    ) -> ListViewController{

        let presentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)
        
        let commentsController = ListViewController.makeWith(
            title: ImageCommentsPresenter.title)
        commentsController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: CommentsViewAdapter(controller: commentsController),
            loadingView: WeakRefVirtualProxy(commentsController),
            errorView: WeakRefVirtualProxy(commentsController),
            mapper: { ImageCommentsPresenter.map($0) }
        )
        
        return commentsController
    }
}

final private class CommentsViewAdapter: ResourceView{
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ resourceViewModel: ImageCommentsViewModel) {
        let cellControllers = resourceViewModel.comments.map{ vm in
            CellController(id: vm, ImageCommentCellController(model: vm))
        }
        controller?.display(cellControllers)
    }
}

private extension ListViewController{
    static func makeWith(title: String) -> ListViewController{
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let commentsController = storyboard.instantiateInitialViewController() as! ListViewController
        commentsController.title = title
        return commentsController
    }
}

