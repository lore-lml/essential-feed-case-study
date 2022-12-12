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
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
}

private extension FeedPresenterTests{
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (presenter: FeedPresenter, view: ViewSpy){
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    final class ViewSpy{
        let messages = [Any]()
        
    }
}
