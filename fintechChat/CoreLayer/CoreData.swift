//
//  CoreData.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 20/03/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack: NSObject {
    
    static let shared = CoreDataStack()
    

    var storeUrl: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //print(documentsURL)
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
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveCdContext () {
        if CoreDataStack.shared.mainContext.hasChanges {
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    class func fetchedResultsController(entityName: String, keyForSort: String, sectionName: String?) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }
}

extension Conversation {
    static func insertNewConversation(in context: NSManagedObjectContext, recieveID: String, isOnline: Bool) -> Conversation? {
        
        guard let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation else { return nil }
        
        conversation.userid = recieveID
        conversation.isOnline = isOnline
        conversation.conversationID = UUID().uuidString
        return conversation
    }
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

    class func cleanDeleteAppUser(in context: NSManagedObjectContext) -> Bool {

        let request: NSFetchRequest<AppUser> = NSFetchRequest(entityName: "AppUser")
        let delete = NSBatchDeleteRequest(fetchRequest: (request as? NSFetchRequest<NSFetchRequestResult>)!)
        do {
            try context.execute(delete)
            return true
        } catch {

            return false
        }
    }
}


extension Message {
    static func insertNewMessage(in context: NSManagedObjectContext, conversationID: String, text: String, recieveID: String, senderID: String, msgID: String) -> Message? {
        
        guard let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message else { return nil }
        
        message.conversationID = conversationID
        message.text = text
        message.timestamp = Date()
        message.recieveID = recieveID
        message.senderID = senderID
        message.messageID = msgID
        return message
    }
}
