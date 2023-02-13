//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Lorenzo Limoli on 13/02/23.
//

import Foundation
import EssentialFeed

var anyNSError:  NSError {
    return NSError(domain: "any error", code: 0)
}

var anyURL: URL {
    return URL(string: "http://any-url.com")!
}

var anyData: Data {
    return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage]{
    return [
        FeedImage(url: .init(string: "http://any-url.com")!, description: "any", location: "any")
    ]
}
