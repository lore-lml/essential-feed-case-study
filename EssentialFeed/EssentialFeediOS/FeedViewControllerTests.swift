//
//  FeedViewControllerTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 13/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest

final class FeedViewController{
    init(loader: FeedViewControllerTests.LoaderSpy){
        
    }
}

final class FeedViewControllerTests: XCTestCase {
   
    func test_init_doesNotLoadFeed(){
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }

}

extension FeedViewControllerTests{
    final class LoaderSpy{
        private(set) var loadCallCount: Int = 0
    }
}
