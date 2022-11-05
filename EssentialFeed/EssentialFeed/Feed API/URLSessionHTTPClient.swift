//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 17/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient{
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private let session: URLSession
    
    private struct UnexpectedValuesRepresentation: Error{}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void){
        session.dataTask(with: url) { data, response, error in
            if let error{
                completion(.failure(error))
            }
            else if let data, let response = response as? HTTPURLResponse{
                completion(.success((data, response)))
            }
            else{
                completion(.failure(UnexpectedValuesRepresentation()))
            }
            
        }.resume()
    }
}
