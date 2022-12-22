//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 15/12/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView(){
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingImageData_sendLoadingMessage(){
        let (sut, view) = makeSUT()
        let feedImage = uniqueImageFeed().models[0]
        
        sut.didStartLoadingImageData(for: feedImage)
        
        XCTAssertEqual(view.messages, [.loading])
    }
    
    func test_didFinishLoadingImageDataWithError_sendFailureMessage(){
        
        let (sut, view) = makeSUT()
        expect(sut, toSend: [.loading, .failure], for: .failure(anyNSError), to: view)
    }
    
    func test_didFinishLoadingImageDataWithData_sendFailureMessageIfTransformerFails(){
        
        let (sut, view) = makeSUT(imageTransformer: { _ in nil })
        expect(sut, toSend: [.loading, .failure], for: .success(Data()), to: view)
    }
    
    func test_didFinishLoadingImageDataWithData_sendSuccessMessageIfTransformerSucceeds(){
        
        let (sut, view) = makeSUT()
        expect(sut, toSend: [.loading, .success], for: .success(Data()), to: view)
    }
}

private extension FeedImagePresenterTests{
    
    func makeSUT(imageTransformer: @escaping (Data) -> Data? = { data in return data }, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, Data>, view: ViewSpy){
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func expect(_ sut: FeedImagePresenter<ViewSpy, Data>, toSend messages: [ViewSpy.Message], for result: Result<Data, Error>, to view: ViewSpy, file: StaticString = #file, line: UInt = #line){
        
        let feedImage = uniqueImageFeed().models[0]
        
        sut.didStartLoadingImageData(for: feedImage)
        
        switch result{
        case let .success(data):
            sut.didFinishLoadingImageData(with: data, for: feedImage)
        case let .failure(err):
            sut.didFinishLoadingImageData(with: err, for: feedImage)
        }
        
        XCTAssertEqual(view.messages, messages, file: file, line: line)
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
