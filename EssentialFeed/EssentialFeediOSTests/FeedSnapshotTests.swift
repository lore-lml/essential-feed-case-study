//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 21/02/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {

    func test_emptyFeed(){
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_feedWithContent(){
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
    
    func test_feedWithErrorMessage(){
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a \nmulti-line\nerror message"))
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
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
    
    func feedWithContent() -> [ImageStub]{
        [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            )
        ]
    }
    
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

private extension FeedViewController{
    func display(_ stubs: [ImageStub]){
        let cells: [FeedImageCellController] = stubs.map{ stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        display(cells)
    }
}

private final class ImageStub: FeedImageCellControllerDelegate{
    
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?){
        viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {}
}