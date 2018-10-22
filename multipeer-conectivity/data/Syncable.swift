//
//  Syncable.swift
//  multipeer-conectivity
//
//  Created by Vincent Berihuete on 10/21/18.
//  Copyright © 2018 devcorerd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol Syncable {
   
    associatedtype Entity
    
    var URL: String {get}
    var context: NSManagedObjectContext? {get}
    var entityName: String {get}
    
    func load(from: LoadSource, callback: ([Entity]) -> ())
    
    func parse(dataFor data: Entity) -> NSManagedObject
    
    func parse(dataFrom managedObject: NSManagedObject) -> Entity
}

enum LoadSource{
    case local
    case server
}


extension Syncable{
    
    var context: NSManagedObjectContext?{
        guard let appDeleagte = UIApplication.shared.delegate as? AppDelegate else{
            return nil
        }
        
        return appDeleagte.persistentContainer.viewContext
    }
    
    /// Persist into core data a given entity
    ///
    /// - Parameter data: The entity to be persisted
    func persist(data: Entity){
        _ = parse(dataFor: data)
        performContextSave()
    }
    
    
    /// Persist into core data a given array of entities to be persisted
    ///
    /// - Parameters:
    ///   - batch: The array of entities
    ///   - amount: THe amount of each bach save, when the for loop count reaches the given amount it wil perform a context save
    func persist(batch: [Entity], of amount: Int = 100){
        
        for (i, entity) in batch.enumerated(){
            _ = parse(dataFor: entity)
            if (i % 100 == 0 || i == batch.count - 1){
                performContextSave()
            }
        }
    }
    
    
    /// Erases all the content of the current core data model
    func wipeOut(){
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        _ = try? context?.execute(request)
    }
    
    
    /// Performs a context save
    func performContextSave(){
        do {
            try context?.save()
            
        } catch{
            print("Failed saving with error \(error.localizedDescription)")
        }
    }
}
