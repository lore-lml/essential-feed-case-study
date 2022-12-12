//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 12/12/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct FeedLoadingViewModel{
    let isLoading: Bool
}

struct FeedViewModel{
    let feed: [FeedImage]
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

protocol FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView{
    func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter{
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView){
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
    }
    
    func didFinishedLoadingFeed(with feed: [FeedImage]){
        feedView.display(.init(feed: feed))
        loadingView.display(.init(isLoading: false))
    }
}

final class FeedPresenterTests: XCTestCase {

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
    
    func test_didFinishLoadingFeed_displaysFeedAndStopLoading(){
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed().models
        
        sut.didFinishedLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
            .display(isLoading: false)
        ])
    }
}

private extension FeedPresenterTests{
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (presenter: FeedPresenter, view: ViewSpy){
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
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
