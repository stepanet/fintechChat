//
//  ConversationsListViewController.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 21/02/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData

class ConversationsListViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet var tableView: UITableView!

    /*1*/
    let coreDate = CoreDataStack.shared
    let messageServiceType = "tinkoff-chat"
    let discoveryInfo = ["userName": UIDevice.current.name + " DmitryPyatin"]
    var myPeerId: MCPeerID!
    var session: MCSession!
    var fromUserPeer: MCPeerID!

    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!
    
    var fetchedResultsController = CoreDataStack.fetchedResultsController(entityName: "Conversation", keyForSort: "isOnline", sectionName: "isOnline")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchedResultsController.delegate = self
        tableView.delegate = self
        myPeerId = MCPeerID(displayName: UIDevice.current.name + " DmitryPyatin")

        //Делаем устройство видимым для других
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: discoveryInfo, serviceType: messageServiceType)
        //Ищем другие устройства
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: messageServiceType)

        session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self

        //включаем видимость
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()

        //включаем поиск
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    deinit {
       serviceAdvertiser.stopAdvertisingPeer()
       serviceBrowser.stopBrowsingForPeers()
    }

    override func viewDidAppear(_ animated: Bool) {
        session.delegate = self
        navBarBtnSetup()
        loadData()
    }
    
    func navBarBtnSetup() {

        let model = coreDate.managedObjectModel
        let user = AppUser.fetchRequest(model: model, templateName: "AppUser")
        coreDate.masterContext.perform {
            let result =  try? self.coreDate.masterContext.fetch(user!)
            if result!.isEmpty {
                return
            }
            var image = UIImage(data: (result?.first?.image)!)
            let size = CGSize(width: 40, height: 40)
            image = image!.resizeImage(targetSize: size)
            DispatchQueue.main.async {
                let button = UIButton()
                button.layer.cornerRadius = 20
                button.clipsToBounds = true
                button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                button.setImage(image, for: .normal)
                button.addTarget(self, action: #selector(self.pressAction), for: .touchUpInside)
                let barButton = UIBarButtonItem()
                barButton.customView = button
                self.navigationItem.rightBarButtonItem = barButton
            }
        }
    }

    @objc func pressAction() {
        self.navigationController?.popToRootViewController(animated: true)
        performSegue(withIdentifier: "ShowDetailsProfile", sender: self)
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    //core data
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Online" : "History"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = self.fetchedResultsController.sections {
            return sections.count
        } else {
            return 0
        }
    }
    
    private func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        print(#function)
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        print(#function)
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        print(#function)
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("DELETE INDEX PATH")
            
            let managedObject = fetchedResultsController.object(at: indexPath as IndexPath) as! NSManagedObject
            print("managedObjectmanagedObjectmanagedObject", managedObject)
        }
    }
}

extension ConversationsListViewController: UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = fetchedResultsController.object(at: indexPath) as? Conversation
        performSegue(withIdentifier: "showDetails", sender: message)
    }

    //подготовка данных для пересылки во вьюконтроллер
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if segue.identifier == "showDetails" {
        let controller = segue.destination as! ConversationViewController
        controller.conversation = sender as? Conversation
        controller.session = session
        controller.peerID = fromUserPeer
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*2*/      
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = fetchedResultsController.object(at: indexPath) as! Conversation
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConversationTableViewCell
        
        var text: String?
        var datetxt: Date?

        let requestMess = FetchRequestManager.shared.fetchLastMessageWithConversationId(conversationID: conversation.conversationID!)
        
        do {
            let result =  try CoreDataStack().mainContext.fetch(requestMess)
            text = result.first?.text
            datetxt = result.first?.timestamp
        } catch {
            print(error)
        }

        cell.nameLbl.text = conversation.userid
        cell.messageLbl.text = text
        if datetxt != nil {
            cell.dateLbl.text = Service.shared.dateString(date: datetxt!)
        }
        return cell
    }
    
    func loadData() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        DispatchQueue.main.async {
            self.view.backgroundColor = ThemeManager.currentTheme().backgroundColor
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    
    //НЕ РАБОТАЕТ!!!  методы не вызываются. почему то
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .insert:
            print("insert controller")
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
            }
            print("INSERT NEW VALUE")
        case .update:
            if let indexPath = indexPath {
                let conversation = fetchedResultsController.object(at: indexPath as IndexPath) as! Conversation
                let cell = tableView.cellForRow(at: indexPath as IndexPath)
                cell!.textLabel?.text = conversation.conversationID
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath as IndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerDidChangeContent")
        tableView.endUpdates()
    }
}

extension ConversationsListViewController: MCNearbyServiceAdvertiserDelegate {

    //Узнаем, что видимость не включилась
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer: \(error)")
    }

    //Получили приглашение
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
       print("didReceiveInvitationFromPeer \(peerID)")

        if session.connectedPeers.contains(peerID) {
            invitationHandler(false, nil)
        } else {
            invitationHandler(true, session)
        }
    }
}

extension ConversationsListViewController: MCNearbyServiceBrowserDelegate {
    //что то пошло не так
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("didNotStartBrowsingForPeers: \(error)")
    }

    //кого то нашли
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        //это пир кто к нам подключился
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    //кто то пропал
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("потеряли участника: \(peerID)")
        let lostUserConnect = FetchRequestManager.shared.fetchConversationWithID(id: peerID.displayName)

            do {
                let result =  try CoreDataStack.shared.mainContext.fetch(lostUserConnect)
                let objectUpdate = result[0] as! NSManagedObject
                //print("objectUpdate",objectUpdate.conversationID)
                //print(objectUpdate.isOnline)
                objectUpdate.setValue(false, forKey: "isOnline")
                objectUpdate.setValue("fFFFFFF", forKey: "userid")
                objectUpdate.setValue("fFFFFFF", forKey: "conversationID")
                //print(objectUpdate.isOnline)

            } catch {
                print("error")
            }
        
        CoreDataStack.shared.mainContext.perform {
            _ = try! CoreDataStack.shared.mainContext.save()
        }

//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            print(error)
//        }
       // self.loadData()
    }
}

extension ConversationsListViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {

        
        if state.rawValue == 2 {
            print("участник \(peerID) изменил состояние: \(state.rawValue)")
            fromUserPeer = peerID
            
            
            //добавим новый чат в коре дата если чата с таким пользователем еще нет

            let request = FetchRequestManager.shared.fetchConversationWithID(id: peerID.displayName)
            coreDate.mainContext.perform {
            do {
                let result =  try self.coreDate.mainContext.fetch(request)
                if result.count == 0 {
                    self.coreDate.masterContext.perform {
                        _ = Conversation.insertNewConversation(in: self.coreDate.masterContext, recieveID: peerID.displayName, isOnline: true)
                        try? self.coreDate.masterContext.save()
                    }
                }
            } catch {
                print(error)
            }
    }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.loadData()
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let jsonDecoder = JSONDecoder()
        var str: String?
        var msgId: String?
        print("try save didReceiveData")
        
        
        do {
            let msg = try jsonDecoder.decode(MessageType.self, from: data)
            str = msg.text
            msgId = msg.messageId
        } catch {
            print(error)
        }

        let requestConvID: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        requestConvID.predicate = NSPredicate(format: "userid == %@", peerID.displayName)
        self.coreDate.masterContext.perform {
        let result =  try! self.coreDate.masterContext.fetch(requestConvID)
        
            _ = Message.insertNewMessage(in: self.coreDate.masterContext, conversationID: result.first!.conversationID!, text: str!, recieveID: self.myPeerId.displayName, senderID: peerID.displayName, msgID: msgId!)
            try? self.coreDate.masterContext.save()
        }
//            do {
//                try self.fetchedResultsController.performFetch()
//            } catch {
//                print(error)
//            }
        self.loadData()
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
}
