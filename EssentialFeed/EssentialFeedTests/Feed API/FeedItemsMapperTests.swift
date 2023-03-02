//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 06/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedItemsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]
        
        let json = makeItemsJSON([])
        try samples.forEach{ code in
            XCTAssertThrowsError(
                try map(json, from: .init(code: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() throws{
        let invalidJSON = Data("invalid json".utf8)
        XCTAssertThrowsError(
            try map(invalidJSON, from: .init(code: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws{
        let emptyListJSON = makeItemsJSON([])
        let result = try map(emptyListJSON, from: .init(code: 200))
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws{
        let (item1, item1JSON) = makeItem(imageURL: URL(string: "http://a-url.com")!)
        
        let (item2, item2JSON) = makeItem(description: "a description", location: "a location", imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1, item2]
        let itemsJson = [item1JSON, item2JSON]
        
        let json = makeItemsJSON(itemsJson)
        let result = try map(json, from: .init(code: 200))
        
        XCTAssertEqual(result, items)
    }
}


private extension FeedItemsMapperTests{
    
    func makeItem(id: UUID = .init(), description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]){
        
        let model = FeedImage(id: id, url: imageURL, description: description, location: location)
        
        let json = [
            "id": model.id.uuidString,
            "image": model.url.absoluteString,
            "description": model.description,
            "location": model.location
        ]
            .compactMapValues{ $0 }
        
        return (model, json)
    }
    
    func makeItemsJSON(_ items: [[String: Any]]) -> Data{
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage]{
        try FeedItemsMapper.map(data, from: response)
    }
}


private extension HTTPURLResponse{
    convenience init(code: Int) {
        self.init(url: anyURL, statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}
