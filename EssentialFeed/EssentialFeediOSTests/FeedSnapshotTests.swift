//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 21/02/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {

    func test_emptyFeed(){
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
        
        return
    }

}

// MARK: HELPERS

private extension FeedSnapshotTests{
    func makeSUT() -> FeedViewController{
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    func emptyFeed() -> [FeedImageCellController]{ [] }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line){
        guard let snapshotData = snapshot.pngData() else {
            return XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do{
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        }catch{
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
}


private extension UIViewController{
    func snapshot() -> UIImage{
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
