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
    
    struct UnexpectedValuesRepresentation: Error{}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { data, response, error in
            if let error{
                completion(.failure(error))
            }
            else if let data, !data.isEmpty, let response = response as? HTTPURLResponse{
                completion(.success((data, response)))
            }
            else{
                completion(.failure(UnexpectedValuesRepresentation()))
            }
            
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }
    
    func test_getFromURL_performsGETRequestWithURL(){
        let url = anyURL
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
        let error = anyNSError
        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as? NSError
        XCTAssertEqual(error.domain, receivedError?.domain)
        XCTAssertEqual(error.code, receivedError?.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases(){
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
    }
    
    func test_getFromURL_succeedsOnHTTPULRResponseWithData(){
        let data = anyData
        let response = anyHTTPURLResponse
        URLProtocolStub.stub(data: data, response: response, error: nil)

        let exp = expectation(description: "Wait for success")
        makeSUT().get(from: anyURL) { result in
            switch result{
            case .success((let receivedData, let receivedResponse)):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            case .failure:
                XCTFail("Expected success, got \(result)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: Helpers
private extension URLSessionHTTPClientTests{
    
    var anyURL: URL{ .init(string: "http://any-url.com")! }
    var anyData: Data{ .init("any data".utf8) }
    var anyNSError: NSError{ .init(domain: "any error", code: 1) }
    var nonHTTPURLResponse: URLResponse{ .init(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil) }
    var anyHTTPURLResponse: HTTPURLResponse{ .init(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)! }
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient{
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error?{
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for completion")
        var receivedError: Error?
        makeSUT().get(from: anyURL){ result in
            switch result{
            case .failure(let err):
                receivedError = err
            default:
                XCTFail("Expected failure got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
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
