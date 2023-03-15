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
    
    func test_onEnteringBackground_deleteExpiredFeedCache(){
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache(){
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to keep  non-expired cache")
    }
    
    func test_onFeedImageSelection_displaysComments() {
        let comments = showCommentsForFirstImage()
        
        XCTAssertEqual(comments.numberOfRenderedComments(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
    }
}

// MARK: Helepers
extension FeedAcceptanceTests{
    
    func launch(httpClient: HTTPClientStub = .offline, store: InMemoryFeedStore = .empty) -> ListViewController{
        let store = store
        let httpClient = httpClient
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! ListViewController
    }
    
    func enterBackground(with store: InMemoryFeedStore){
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    func showCommentsForFirstImage() -> ListViewController{
        let feedVC = launch(httpClient: .online(response(for:)), store: .empty)
        
        feedVC.simulateTapOnFeedImage(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = feedVC.navigationController
        return nav?.topViewController as! ListViewController
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
        
        private init(feedCache: CachedFeed? = nil) {
            self.feedCache = feedCache
        }
        
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
        
        static var withExpiredFeedCache: InMemoryFeedStore{
            InMemoryFeedStore(feedCache: (feed: [], timestamp: Date.distantPast))
        }
        
        static var withNonExpiredFeedCache: InMemoryFeedStore{
            InMemoryFeedStore(feedCache: (feed: [], timestamp: Date()))
        }
    }
    
    func response(for url: URL) -> (Data, HTTPURLResponse){
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    func makeData(for url: URL) -> Data{
        switch url.path{
        case "/image-1", "/image-2":
            return makeImageData()
            
        case "/essential-feed/v1/feed":
            return makeFeedData()
            
        case "/essential-feed/v1/image/11E123D5-1272-4F17-9B91-F3D0FFEC895A/comments":
            return makeCommentsData()
            
        default:
            return Data()
        }
    }
        
    func makeImageData() -> Data{
        UIImage.make(withColor: .red).pngData()!
    }
    
    func makeFeedData() -> Data{
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "11E123D5-1272-4F17-9B91-F3D0FFEC895A", "image": "http://image.com/image-1"],
            ["id": "31768993-1A2E-4B65-BD2A-D8AF06416730", "image": "http://image.com/image-2"]
        ]])
    }
    
    func makeCommentsData() -> Data{
        return try! JSONSerialization.data(withJSONObject: ["items": [
            [
                "id": UUID().uuidString,
                "message": makeCommentMessage(),
                "created_at": "2022-01-09T11:24:59+0000",
                "author": [ "username": "Joe" ]
            ],
        ]])
    }
    
    func makeCommentMessage() -> String{
        "a message"
    }
}
