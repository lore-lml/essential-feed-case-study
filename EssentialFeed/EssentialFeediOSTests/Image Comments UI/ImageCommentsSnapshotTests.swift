//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 07/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed
import EssentialFeediOS

final class ImageCommentsSnapshotTests: XCTestCase {

    func test_listWithComments(){
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "IMAGE_COMMENTS_WITH_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "IMAGE_COMMENTS_WITH_dark")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_WITH_light_extraExtraExtraLarge")
    }

}

// MARK: HELPERS
private extension ImageCommentsSnapshotTests{
    func makeSUT() -> ListViewController{
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    func comments() -> [CellController]{
        commentsControllers().map{ CellController(id: UUID(), $0) }
    }
    
    func commentsControllers() -> [ImageCommentCellController]{
        [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "East Side Gallery\nMemorial in Berlin, Germany",
                    date: "10 days ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "Nice",
                    date: "1 hour ago",
                    username: "a."
                )
            ),
        ]
    }
}
