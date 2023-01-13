//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Lorenzo Limoli on 17/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData(){
        switch getFeedResult(){
        case .success(let imageFeed):
            XCTAssertEqual(imageFeed.count, 8, "Expected 8 images in the test account image feed. Got \(imageFeed.count).")
            // In this case is preferrable write single lines of codes instead of a for loop because we know ho much items it will returns and they are not so many. This will enable a much clear error finding in case of errors
            XCTAssertEqual(imageFeed[0], expectedImage(at: 0))
            XCTAssertEqual(imageFeed[1], expectedImage(at: 1))
            XCTAssertEqual(imageFeed[2], expectedImage(at: 2))
            XCTAssertEqual(imageFeed[3], expectedImage(at: 3))
            XCTAssertEqual(imageFeed[4], expectedImage(at: 4))
            XCTAssertEqual(imageFeed[5], expectedImage(at: 5))
            XCTAssertEqual(imageFeed[6], expectedImage(at: 6))
            XCTAssertEqual(imageFeed[7], expectedImage(at: 7))
            
        case .failure(let err):
            XCTFail("Expected successful feed result, got \(err) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }

    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData(){
        switch getFeedImageDataResult(){
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }
}

private extension EssentialFeedAPIEndToEndTests{
    func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result?{
        
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: feedTestServerURL, client: client)
        
        let exp = expectation(description: "Wait for load completion")
        var receivedResult: FeedLoader.Result?
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 30)
        return receivedResult
    }
    
    func getFeedImageDataResult(file: StaticString = #filePath, line: UInt = #line) -> FeedImageDataLoader.Result?{
        let url = feedTestServerURL.appendingPathComponent("73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "Wait for load completion")

        var receivedResult: FeedImageDataLoader.Result?
        _ = loader.loadImageData(from: url) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        return receivedResult
    }
    
    var feedTestServerURL: URL{
        return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }
    
    func expectedImage(at index: Int) -> FeedImage{
        .init(
            id:             FeedItemSample.id(at: index),
            url:            FeedItemSample.imageURL(at: index),
            description:    FeedItemSample.description(at: index),
            location:       FeedItemSample.location(at: index)
        )
    }
}
