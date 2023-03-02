//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 26/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

var anyURL: URL{ .init(string: "http://any-url.com")! }
var anyNSError: NSError{ .init(domain: "any error", code: 1) }
var anyData: Data { .init("any data".utf8) }

func makeItemsJSON(_ items: [[String: Any]]) -> Data{
    let itemsJSON = ["items": items]
    return try! JSONSerialization.data(withJSONObject: itemsJSON)
}

extension HTTPURLResponse{
    convenience init(code: Int) {
        self.init(url: anyURL, statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}
