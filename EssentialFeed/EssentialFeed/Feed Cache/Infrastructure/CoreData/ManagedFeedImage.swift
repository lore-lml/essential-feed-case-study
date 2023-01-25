//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 02/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject{
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage{
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet{
        
        let managedFeed = localFeed.map{
            let managedFeedImage = ManagedFeedImage(context: context)
            managedFeedImage.id = $0.id
            managedFeedImage.imageDescription = $0.description
            managedFeedImage.location = $0.location
            managedFeedImage.url = $0.url
            return managedFeedImage
        }
        return NSOrderedSet(array: managedFeed)
    }
    
    var local: LocalFeedImage{
        LocalFeedImage(
            id          : id,
            url         : url,
            description : imageDescription,
            location    : location
        )
    }
}

extension ManagedFeedImage{
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage?{
        let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
