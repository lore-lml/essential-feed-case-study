//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 12/12/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest

final class FeedPresenter{
    
    init(view: Any){
        
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView(){
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
}

private extension FeedPresenterTests{
    final class ViewSpy{
        let messages = [Any]()
        
    }
}
