//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 21/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

extension FeedUIIntegrationTests{
    private final class DummyView: ResourceView{
        typealias ResourceViewModel = String
        func display(_ viewModel: String) {}
    }
    private typealias GenericPresenter = LoadResourcePresenter<Any, DummyView>
    
    var loadError: String{ GenericPresenter.loadError }
    
    var feedTitle: String{ FeedPresenter.title }
    
    var commentsTitle: String{ ImageCommentsPresenter.title }
}


