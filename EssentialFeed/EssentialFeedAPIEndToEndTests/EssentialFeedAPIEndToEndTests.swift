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
        case .success(let items):
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test account feed. Got \(items.count).")
            // In this case is preferrable write single lines of codes instead of a for loop because we know ho much items it will returns and they are not so many. This will enable a much clear error finding in case of errors
            XCTAssertEqual(items[0], expectedItem(at: 0))
            XCTAssertEqual(items[1], expectedItem(at: 1))
            XCTAssertEqual(items[2], expectedItem(at: 2))
            XCTAssertEqual(items[3], expectedItem(at: 3))
            XCTAssertEqual(items[4], expectedItem(at: 4))
            XCTAssertEqual(items[5], expectedItem(at: 5))
            XCTAssertEqual(items[6], expectedItem(at: 6))
            XCTAssertEqual(items[7], expectedItem(at: 7))
            
        case .failure(let err):
            XCTFail("Expected successful feed result, got \(err) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }

}

private extension EssentialFeedAPIEndToEndTests{
    func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> LoadFeedResult?{
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
        let exp = expectation(description: "Wait for load completion")
        var receivedResult: LoadFeedResult?
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 30)
        return receivedResult
    }
    
    func expectedItem(at index: Int) -> FeedItem{
        .init(
            id:             FeedItemSample.id(at: index),
            imageURL:       FeedItemSample.imageURL(at: index),
            description:    FeedItemSample.description(at: index),
            location:       FeedItemSample.location(at: index)
        )
    }
}