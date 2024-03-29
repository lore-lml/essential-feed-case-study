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
    
    func test_didFinishedLoadingWithError_displaysLocalizedErrorMessageAndStopLoading(){
        let (sut, view) = makeSUT()
        
        
        sut.didFinishedLoading(with: anyNSError)
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: loadError),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishedLoadingWithMapperError_displaysLocalizedErrorMessageAndStopLoading(){
        let (sut, view) = makeSUT(mapper: { _ in throw anyNSError })
        
        sut.didFinishedLoading(with: "resource")
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: loadError),
            .display(isLoading: false)
        ])
    }
}

private extension LoadResourcePresenterTests{
    typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    func makeSUT(mapper: @escaping SUT.Mapper = { _ in "any" },
                 file: StaticString = #filePath,
                 line: UInt = #line
    ) -> (presenter: SUT, view: ViewSpy){
        let view = ViewSpy()
        let sut = SUT(
            resourceView: view,
            loadingView: view,
            errorView: view,
            mapper: mapper
        )
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    var loadError: String{ SUT.loadError }
    
    final class ViewSpy: ResourceView, ResourceLoadingView, ResourceErrorView {
        typealias ResourceViewModel = String
        
        enum Message: Hashable{
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        
        private(set) var messages = Set<Message>()
        
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
        
        func display(_ viewModel: ResourceErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }
}
