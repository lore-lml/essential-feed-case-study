//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Lorenzo Limoli on 15/02/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class EssentialAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity(){
        let app = XCUIApplication()
        app.launchArguments = ["-reset"]
        app.launch()

        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasConnectivity(){
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-reset"]
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 22)
        
        let firstImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache(){
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-reset", "-connectivity", "offline"]
        offlineApp.launch()
        
        let feedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 0)
    }
}
