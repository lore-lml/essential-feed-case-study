//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 01/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class ImageCommentsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let json = makeItemsJSON([])
        try badSamples.forEach{ code in
            XCTAssertThrowsError(
                try map(json, from: .init(code: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        try goodSamples.forEach{ code in
            XCTAssertThrowsError(
                try map(invalidJSON, from: .init(code: code))
            )
        }
    }
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
        
        let emptyListJSON = makeItemsJSON([])
        try goodSamples.forEach{ code in
            let result = try map(emptyListJSON, from: .init(code: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        
        let (item1, item1JSON) = makeItem(
            message: "a message",
            createdAt: (date: .init(timeIntervalSince1970: 1598627222), iso8601String: "2020-08-28T15:07:02+00:00"),
            username: "a username"
        )
        
        let (item2, item2JSON) = makeItem(
            message: "another message",
            createdAt: (date: .init(timeIntervalSince1970: 1577881882), iso8601String: "2020-01-01T12:31:22+00:00"),
            username: "another username"
        )
        
        let items = [item1, item2]
        let itemsJson = [item1JSON, item2JSON]
        let json = makeItemsJSON(itemsJson)
        
        try goodSamples.forEach{ code in
            let result = try map(json, from: .init(code: code))
            XCTAssertEqual(result, items)
        }
    }
}


private extension ImageCommentsMapperTests{
    // MARK: Helpers
    
    var badSamples: [Int] { [150, 199, 300, 400, 500] }
    var goodSamples: [Int] { [200, 201, 250, 280, 299]}
    
    private func makeItem(id: UUID = .init(), message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]){
        
        let model = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        
        return (model, json)
    }
    
    func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment]{
        try ImageCommentsMapper.map(data, from: response)
    }
    
}
