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
    
    func test_title_isLocalized(){
        XCTAssertEqual(LoadResourcePresenter.title, localized("FEED_VIEW_TITLE"))
    }

    func test_init_doesNotSendMessagesToView(){
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading(){
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishedLoadingFeed_displaysFeedAndStopLoading(){
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed().models
        
        sut.didFinishedLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
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
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (presenter: LoadResourcePresenter, view: ViewSpy){
        let view = ViewSpy()
        let sut = LoadResourcePresenter(feedView: view, loadingView: view, errorView: view)
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
    
    final class ViewSpy: FeedView, FeedLoadingView, FeedErrorView {
        enum Message: Hashable{
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var messages = Set<Message>()
        
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }
}
