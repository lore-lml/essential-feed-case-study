//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Lorenzo Limoli on 18/02/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity(){
        let feedVC = launch(httpClient: .online(response(for:)))
        
        XCTAssertEqual(feedVC.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feedVC.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feedVC.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity(){
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response(for:)), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache(){
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }
}

// MARK: Helepers
extension FeedAcceptanceTests{
    
    func launch(httpClient: HTTPClientStub = .offline, store: InMemoryFeedStore = .empty) -> FeedViewController{
        let store = store
        let httpClient = httpClient
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    final class HTTPClientStub: HTTPClient{
        class Task: HTTPClientTask{
            func cancel(){}
        }
        
        let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub{
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub{
            HTTPClientStub(stub: { url in .success(stub(url)) })
        }
    }
    
    final class InMemoryFeedStore: FeedStore, FeedImageDataStore{
        var feedCache: CachedFeed?
        var feedImageDataCache: [URL: Data] = [:]
        
        func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
            completion(.success(feedCache))
        }
        
        func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
            feedCache = (feed, timestamp)
            completion(.success(()))
        }
        
        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }
        
        static var empty: InMemoryFeedStore{
            InMemoryFeedStore()
        }
    }
    
    func response(for url: URL) -> (Data, HTTPURLResponse){
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    func makeData(for url: URL) -> Data{
        switch url.absoluteString{
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
        
    func makeImageData() -> Data{
        UIImage.make(withColor: .red).pngData()!
    }
    
    func makeFeedData() -> Data{
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}
