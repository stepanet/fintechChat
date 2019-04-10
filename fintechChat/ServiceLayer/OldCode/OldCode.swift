//
//  OldCode.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 05/04/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import Foundation






//сюда перенесем ненужный код


/*1*/
//    var conversationLists = [ConversationList]()
//    var conversationListsOnline = [ConversationList]()
//    var conversationListsHistory = [ConversationList]()
//    var conversationData = [ConversationList]()
//    var messageLists = [MessageLists]()
//    var messageListClass: MessageListClass!

//let messageService = MultiPeerCommunicator()
//слияние газпрома и роснефти прошло успешно
//а евро тем временем в инвестициях = 72.55

/*2*/
//    return section == 0 ? conversationListsOnline.count : conversationListsHistory.count

/*3*/
//        conversationLists.removeAll()
//        conversationListsOnline.removeAll()
//        conversationListsHistory.removeAll()


/*4*/
/*
 let dateFormatter = DateFormatter()
 dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
 
 
 let item = ConversationList(name: "Вася", message: "Привет, как дела?", date: dateFormatter.date(from: "2019-01-01 01:11:01"), online: false, hasUnreadMessage: true)
 conversationLists.append(item)
 
 for i in conversationLists {
 if i.online {
 conversationListsOnline.append(i)
 } else {
 conversationListsHistory.append(i)
 }
 
 } */
/*5*/
//        if let index = conversationListsOnline.firstIndex(where: { $0.name == peerID.displayName }) {
//            conversationListsHistory.append(conversationListsOnline[index])
//            conversationListsOnline.remove(at: index)
//        }

/*6*/
//            if self.conversationListsOnline.contains(where: { $0.name == peerID.displayName }) {
//                if indexHistory != nil { conversationListsHistory.remove(at: indexHistory!) }
//            } else {
//                if indexHistory != nil
//                {
//                    conversationListsOnline.append(conversationListsHistory[indexHistory!])
//                    conversationListsHistory.remove(at: indexHistory!)
//                } else {
//                    let item = ConversationList(name: peerID.displayName, message: nil, date: Date(), online: true, hasUnreadMessage: true, peerID: peerID)
//                self.conversationListsOnline.append(item)
//
//
//
//                }
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }

/*7*/
//print(str)
//let index = conversationListsOnline.firstIndex(where: { $0.name == peerID.displayName })

//        if str.count > 0 {
//            //убираем из массива, чтобы видеть последнее сообщение
//            self.conversationListsOnline.remove(at: index!)
//            let itemMessage = MessageLists(text: str, fromUser: peerID.displayName, toUser: myPeerId.displayName )
//            let item = ConversationList(name: peerID.displayName, message: str, date: Date(), online: true, hasUnreadMessage: true, peerID: peerID)
//            self.messageLists.append(itemMessage)
//            //self.messageListClass.saveDataToArray(text: str, fromUser: peerID.displayName, toUSer: myPeerId.displayName)
//            self.conversationListsOnline.append(item)
//        }


/*viewDidLoad*/


//        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "isOnline", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
//        var fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDate.mainContext,  sectionNameKeyPath: "isOnline",
//                                         cacheName: nil) as! NSFetchedResultsController<NSFetchRequestResult>
//        fetchedResultsController.delegate = self
//        try! fetchedResultsController.performFetch()
//        let conversation = fetchedResultsController.fetchedObjects
//        print(conversation!)

//messageService.delegate = self

//      fetchedResultsController.delegate = self

//        try! fetchedResultsController.performFetch()
//        let conversation = fetchedResultsController.fetchedObjects
//print(conversation)


//    var fetchedResultsController:NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
//        let sortDescriptor = NSSortDescriptor(key: "isOnline", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack().mainContext, sectionNameKeyPath: "isOnline", cacheName: nil)
//        return fetchedResultsController
//    }()




/*didSelectRowAt*/
//        if indexPath.section == 0 {
//            conversationData = [conversationListsOnline[indexPath.row]]
//        } else {
//            conversationData = [conversationListsHistory[indexPath.row]]
//        }

//_ = self.navigationController?.popToRootViewController(animated: true)
//performSegue(withIdentifier: "showDetails", sender: self)
//tableView.isEditing = true




/*cellForRowAt*/
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ConversationTableViewCell {
//
//            switch indexPath.section {
//            case 0:
//                let itemCellOnline = conversationListsOnline[indexPath.row]
//                cell.nameLbl.textColor = ThemeManager.currentTheme().subtitleTextColor
//                cell.messageLbl.textColor = ThemeManager.currentTheme().subtitleTextColor
//                cell.dateLbl.textColor = ThemeManager.currentTheme().subtitleTextColor
//                cell.backgroundColor = UIColor(named: "littelYellow")
//                cell.dataCell(itemCellOnline)
//            case 1:
//                let itemCellHistory = conversationListsHistory[indexPath.row]
//                cell.backgroundColor = ThemeManager.currentTheme().backgroundColor
//                cell.nameLbl.textColor = ThemeManager.currentTheme().titleTextColor
//                cell.messageLbl.textColor = ThemeManager.currentTheme().titleTextColor
//                cell.dateLbl.textColor = ThemeManager.currentTheme().titleTextColor
//                cell.dataCell(itemCellHistory)
//            default:
//                break
//            }
//
//            return cell
//        }
//        return UITableViewCell()


/*segue*/
//        if let destination = segue.destination as? ConversationViewController {
//            destination.session = session
//            //destination.conversationData = conversationData
//            //destination.messageLists = messageLists
//            //destination.messageListClass = messageListClass
//        }





//        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as? MessageTableViewCell
//        let text = "" //messageLists[indexPath.row].text
//        cell!.messageText.text = text
//        return cell!

//        if (messageLists[indexPath.row].toUser == session.myPeerID.displayName ) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as? MessageTableViewCell
//            let text = messageLists[indexPath.row].text
//            cell!.messageText.text = text
//            return cell!
//        } else if (messageLists[indexPath.row].toUser != session.myPeerID.displayName ) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageTableViewCell
//            let text = messageLists[indexPath.row].text
//            cell?.messageText.text = text
//            return cell!
//        } else {
//            print("печатаем ячейку")
//            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageTableViewCell
//            let text = messageLists[indexPath.row].text
//            cell?.messageText.text = text
//            return cell!
//        }
