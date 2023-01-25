//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 31/10/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore{
    
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error{
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws{
        guard let model = Self.model else{
            throw StoreError.modelNotFound
        }
        
        do{
            container = try NSPersistentContainer.load(name: Self.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
            
        }catch{
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    
    func perform(_ block: @escaping (NSManagedObjectContext) -> Void){
        let context = self.context
        context.perform{
            block(context)
        }
    }
    
    private func cleanUpReferencesToPersistentStores(){
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit{
        cleanUpReferencesToPersistentStores()
    }
}
