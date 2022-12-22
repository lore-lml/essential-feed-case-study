//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 15/12/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewModel<Image>)
}

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image{
    
    private let view: View
    
    init(view: View){
        self.view = view
    }
    
    func didStartLoadingImageData(for model: FeedImage){
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
}

final class FeedImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView(){
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingImageData_sendDisplayFeedMessage(){
        let (sut, view) = makeSUT()
        let feedImage = uniqueImageFeed().models[0]
        
        sut.didStartLoadingImageData(for: feedImage)
        
        XCTAssertEqual(view.messages, [.loading])
    }
}

private extension FeedImagePresenterTests{
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, Data>, view: ViewSpy){
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    final class ViewSpy: FeedImageView{
        
        typealias Image = Data
        
        enum Message: Hashable{
            case loading
            case success
            case failure
            case unexpected
        }
        
        var messages = [Message]()
        
        func display(_ model: FeedImageViewModel<Data>) {
            
            let message: Message
            switch (model.image, model.isLoading, model.shouldRetry){
            case (.none, true, false):
                message = .loading
                
            case (.some, false, false):
                message = .success
                
            case (.none, false, true):
                message = .failure
                
            default:
                message = .unexpected
            }
            
            messages.append(message)
        }
    }
}
