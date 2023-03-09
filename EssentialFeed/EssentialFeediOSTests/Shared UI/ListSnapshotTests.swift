//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 07/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed
import EssentialFeediOS

final class ListSnapshotTests: XCTestCase {

    func test_emptyFeed(){
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    func test_listWithErrorMessage(){
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a \nmulti-line\nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
    }
}

private extension ListSnapshotTests{
    func makeSUT() -> ListViewController{
        let controller = ListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.tableView.separatorStyle = .none
        return controller
    }
    
    func emptyFeed() -> [CellController]{ [] }
}
