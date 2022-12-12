//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 12/12/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest

struct FeedLoadingViewModel{
    let isLoading: Bool
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

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter{
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    init(loadingView: FeedLoadingView, errorView: FeedErrorView){
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
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
}

private extension FeedPresenterTests{
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (presenter: FeedPresenter, view: ViewSpy){
        let view = ViewSpy()
        let sut = FeedPresenter(loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    final class ViewSpy: FeedLoadingView, FeedErrorView{
        enum Message: Hashable{
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = Set<Message>()
        
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }
}
