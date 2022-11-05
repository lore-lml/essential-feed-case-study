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

}

private extension EssentialFeedAPIEndToEndTests{
    func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result?{
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
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
    
    func expectedImage(at index: Int) -> FeedImage{
        .init(
            id:             FeedItemSample.id(at: index),
            url:            FeedItemSample.imageURL(at: index),
            description:    FeedItemSample.description(at: index),
            location:       FeedItemSample.location(at: index)
        )
    }
}
