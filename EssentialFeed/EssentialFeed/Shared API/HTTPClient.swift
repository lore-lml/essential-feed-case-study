//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 11/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public protocol HTTPClientTask{
    func cancel()
}

public protocol HTTPClient{
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
        func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
