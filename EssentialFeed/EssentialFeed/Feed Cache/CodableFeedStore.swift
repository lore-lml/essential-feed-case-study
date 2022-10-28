//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 28/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public final class CodableFeedStore: FeedStore{
    
    private struct Cache: Codable{
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage]{
            feed.map(\.local)
        }
    }
    
    private struct CodableFeedImage: Codable {
        
        private let id: UUID
        private let url: URL
        private let description: String?
        private let location: String?
        
        init(_ image: LocalFeedImage){
            self.id          = image.id
            self.url         = image.url
            self.description = image.description
            self.location    = image.location
        }
        
        var local: LocalFeedImage{
            LocalFeedImage(
                id          : id,
                url         : url,
                description : description,
                location    : location
            )
        }
    }
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion){
        guard let data = try? Data(contentsOf: storeURL) else{
            completion(.empty)
            return
        }
        
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        }catch{
            completion(.failure(error))
        }
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion){
        do{
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        }catch{
            completion(error)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion){
        guard FileManager.default.fileExists(atPath: storeURL.path) else{
            completion(nil)
            return
        }
        
        do{
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        }catch{
            completion(error)
        }
    }
}
