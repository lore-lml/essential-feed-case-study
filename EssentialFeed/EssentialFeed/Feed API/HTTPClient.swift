//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 11/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public typealias HTTPClientSuccessResult = (data: Data, response: HTTPURLResponse)

public typealias HTTPClientResult = Result<HTTPClientSuccessResult, Error>

public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
