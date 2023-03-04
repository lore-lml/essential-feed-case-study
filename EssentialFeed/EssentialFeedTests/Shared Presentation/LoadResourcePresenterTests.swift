//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 04/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class LoadResourcePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView(){
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartsLoading(){
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishedLoadingResource_displaysResourceAndStopLoading(){
        let (sut, view) = makeSUT(mapper: { "\($0) view model" })
        
        sut.didFinishedLoading(with: "resource")
        
        XCTAssertEqual(view.messages, [
            .display(resourceViewModel: "resource view model"),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishedLoadingFeed_displaysLocalizedErrorMessageAndStopLoading(){
        let (sut, view) = makeSUT()
        
        
        sut.didFinishedLoadingFeed(with: anyNSError)
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }
}

private extension LoadResourcePresenterTests{
    
    func makeSUT(mapper: @escaping (String) -> String = { _ in "any" },
                 file: StaticString = #file,
                 line: UInt = #line
    ) -> (presenter: LoadResourcePresenter, view: ViewSpy){
        let view = ViewSpy()
        let sut = LoadResourcePresenter(
            resourceView: view,
            loadingView: view,
            errorView: view,
            mapper: mapper
        )
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String{
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key{
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }

        return value
    }
    
    final class ViewSpy: ResourceView, FeedLoadingView, FeedErrorView {
        enum Message: Hashable{
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        
        private(set) var messages = Set<Message>()
        
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }
}
