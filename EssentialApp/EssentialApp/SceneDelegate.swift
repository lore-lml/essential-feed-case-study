//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Lorenzo Limoli on 25/01/23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: .init(configuration: .ephemeral))
    }()
    private lazy var store: (FeedStore & FeedImageDataStore) = {
        let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite")
        return try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        configureWindow()
    }
    
    func configureWindow(){
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        let feedVc = FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primaryLoader: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader),
                fallbackLoader: localFeedLoader
            ),
            imageLoader: FeedImageLoaderWithFallbackComposite(
                primaryLoader: localImageLoader,
                fallbackLoader: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)
            )
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedVc)
    }
}
