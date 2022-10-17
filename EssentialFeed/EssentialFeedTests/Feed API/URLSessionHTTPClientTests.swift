//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 14/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient{
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    private let session: URLSession
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { _, _, error in
            guard let error else { return }
            completion(.failure(error))
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }
    
    func test_getFromURL_performsGETRequestWithURL(){
        
        let url = URL(string: "http://any-url.com")!
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequest{ request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError(){
        
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let exp = expectation(description: "Wait for completion")
        makeSUT().get(from: url){ result in
            switch result{
            case .failure(let receivedError as NSError):
                XCTAssertEqual(error.domain, receivedError.domain)
                XCTAssertEqual(error.code, receivedError.code)
            default:
                XCTFail("Expected failure with error \(error) got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
}

// MARK: Helpers
private extension URLSessionHTTPClientTests{
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient{
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    class URLProtocolStub: URLProtocol{

        private static var requestObserver: ((URLRequest) -> Void)?
        private static var stub: Stub?
        
        private struct Stub{
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?){
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests(){
            URLProtocol.registerClass(Self.self)
        }
        
        static func stopInterceptingRequests(){
            URLProtocol.unregisterClass(Self.self)
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void){
            requestObserver = observer
        }
        
        /// This method indicates whether the request can be handled or not. We obtain an instance of this class only if the request can be handled
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        /// We can modify the request at this point
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
        
        /// At this time we have an instance of the class and the framework accepted to handle the request. Now we should start loading the url
        override func startLoading() {
            
            if let data = Self.stub?.data{
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = Self.stub?.response{
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = Self.stub?.error{
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        //If we don't implement it, we are gonna have a crash
        override func stopLoading() {}
    }
}
