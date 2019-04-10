//
//  FetchRequestManager.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 05/04/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import Foundation
import CoreData

class FetchRequestManager {

    static let shared = FetchRequestManager()


    //последнее сообщение
    func fetchLastMessageWithConversationId(conversationID: String, senderid: String) -> NSFetchRequest<Message> {
        let requestMess: NSFetchRequest<Message> = Message.fetchRequest()
        requestMess.returnsObjectsAsFaults = false
        requestMess.predicate = NSPredicate(format: "senderID == %@ AND conversationID == %@", senderid,  conversationID )
        requestMess.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        requestMess.sortDescriptors = [sortDescriptor]
        return requestMess
    }
    
    func fetchConversationWithID(id: String) -> NSFetchRequest<Conversation>{
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "userid == %@", id)
        request.fetchBatchSize = 25
        request.returnsObjectsAsFaults = false
        return request
    }
    
    
    func fetchMesasgeWithConversationID(id: String) -> NSFetchRequest<Message>{
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "conversationID == %@", id)
        request.fetchBatchSize = 25
        request.returnsObjectsAsFaults = false
        return request
    }
    
    func fetchAllConversation() -> NSFetchRequest<Conversation>{
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.fetchBatchSize = 12
        request.returnsObjectsAsFaults = false
        return request
    }
    
    
}
