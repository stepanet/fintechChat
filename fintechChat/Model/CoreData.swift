//
//  CoreData.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 20/03/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import Foundation
import CoreData


class CoreData: NSObject {
    
    var storeUrl: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
       // print(documentsURL)
        return documentsURL.appendingPathComponent("fintech.sqllite")
    }
    
    
    let dataModelName = "fintech"
    let dataModelExtension = "momd"
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.dataModelName, withExtension: self.dataModelExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeUrl, options: nil)
            
        } catch {
            assert(false, "Error adding store: \(error)")
        }
        return coordinator
    }()
    
    lazy var masterContext: NSManagedObjectContext = {
        var masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType )
        
        //делаем ссылку на coordinatora или на другой NSManagedObjectContext
        masterContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        masterContext.mergePolicy = NSOverwriteMergePolicy
        return masterContext
    }()
    
    
    
    lazy var mainContext: NSManagedObjectContext = {
       var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        //делаем ссылку на coordinatora или на другой NSManagedObjectContext
        //это когда только один конекст
        //mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        mainContext.parent = self.masterContext
        mainContext.mergePolicy = NSOverwriteMergePolicy
        return mainContext
    }()
    
    lazy var saveContext: NSManagedObjectContext = {
        var saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        //делаем ссылку на coordinatora или на другой NSManagedObjectContext
        saveContext.parent = self.mainContext
        saveContext.mergePolicy = NSOverwriteMergePolicy
        return saveContext
    }()
    
}

extension AppUser {
    static func insertAppUser(in context: NSManagedObjectContext, name: String, timestamp: Date, about: String, image: Data) -> AppUser? {
        guard let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser else { return nil }
        
        appUser.name = name
        appUser.timestamp = Date()
        appUser.about = about
        appUser.image = image
        return appUser
    }
    
    static func fetchRequest(model: NSManagedObjectModel, templateName: String) -> NSFetchRequest<AppUser>? {
        
        let templateName = templateName //"AppUser"
        
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
            assert(false, "No template")
            return nil
        }
        return fetchRequest
    }
    
    static func fetchRequest1(model: NSManagedObjectModel, templateName: String) -> NSFetchRequest<AppUser>? {
        
        let templateName = templateName //"AppUser"
        
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
            assert(false, "No template")
            return nil
        }
        return fetchRequest
    }
    
    
    class func cleanDeleteAppUser(in context: NSManagedObjectContext) -> Bool {
        
        let request: NSFetchRequest<AppUser> = NSFetchRequest(entityName: "AppUser")
        let delete = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)

        do {
            try context.execute(delete)
            return true
        }catch {

            return false
        }
    }
}


