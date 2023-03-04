//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 04/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized(){
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

    func test_map_createsViewModels() {
        let now = Date()
        
        let comments = [
            ImageComment(message: "a message", createdAt: Date().adding(minutes: -5), username: "a username"),
            ImageComment(message: "another message", createdAt: Date().adding(days: -1), username: "another username")
        ]
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minuti fa",
                username: "a username"
            ),
            ImageCommentViewModel(
                message: "another message",
                date: "1 giorno fa",
                username: "another username"
            ),
        ])
    }
}

private extension ImageCommentsPresenterTests{
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String{
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key{
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }

        return value
    }
}
