//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 07/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest

extension XCTest{
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line){
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        do{
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        }catch{
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line){
        
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            return XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot beore asserting.", file: file, line: line)
        }
        
        if snapshotData != storedSnapshotData{
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshotURL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL{
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data?{
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return snapshotData
    }
}
