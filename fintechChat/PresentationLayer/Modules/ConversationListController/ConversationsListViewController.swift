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

class ConversationsListViewController: UIViewController,  NSFetchedResultsControllerDelegate {

    @IBOutlet var tableView: UITableView!

    /*1*/
    //let coreDate = CoreDataStack.shared
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
        
        frc()

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
    
    func frc() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    func navBarBtnSetup() {

        let model = CoreDataStack.shared.managedObjectModel
        let user = AppUser.fetchRequest(model: model, templateName: "AppUser")
        CoreDataStack.shared.masterContext.perform {
            let result =  try? CoreDataStack.shared.masterContext.fetch(user!)
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
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//                let managedObject = self.fetchedResultsController.object(at: indexPath as IndexPath) as! NSManagedObject
//                CoreDataStack.shared.mainContext.delete(managedObject)
//                CoreDataStack.shared.saveCdContext()
//        }
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
        let requestMess = FetchRequestManager.shared.fetchLastMessageWithConversationId(conversationID: conversation.conversationID!, senderid: conversation.userid!)
        do {
            let result =  try CoreDataStack.shared.mainContext.fetch(requestMess)
            text = result.first?.text
            datetxt = result.first?.timestamp
        } catch {
            print(error)
        }

        cell.nameLbl.text = conversation.userid
        cell.messageLbl.text = text
        if conversation.isOnline {
            cell.messageLbl.textColor = .green
        } else {
            cell.messageLbl.textColor = ThemeManager.currentTheme().titleTextColor
        }
        if datetxt != nil {
            cell.dateLbl.text = Service.shared.dateString(date: datetxt!)
        }
        
        return cell
    }
    
    func loadData() {
        DispatchQueue.main.async {
            self.view.backgroundColor = ThemeManager.currentTheme().backgroundColor
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerWillChangeContent")
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
            }
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
                let objectUpdate = result[0]
                objectUpdate.setValue(false, forKey: "isOnline")
                CoreDataStack.shared.saveCdContext()
            }  catch {
                print("error")
            }
    }
}

extension ConversationsListViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {

        
        if state.rawValue == 2 {
            print("участник \(peerID) изменил состояние: \(state.rawValue)")
            fromUserPeer = peerID
            
            //добавим новый чат в коре дата если чата с таким пользователем еще нет
            let request = FetchRequestManager.shared.fetchConversationWithID(id: peerID.displayName)
            CoreDataStack.shared.mainContext.perform {
            do {
                let result =  try CoreDataStack.shared.mainContext.fetch(request)
                if result.count == 0 {
                    CoreDataStack.shared.masterContext.perform {
                        _ = Conversation.insertNewConversation(in: CoreDataStack.shared.masterContext, recieveID: peerID.displayName, isOnline: true)
                        try? CoreDataStack.shared.masterContext.save()
                    }
                } else  {
                        result[0].setValue(true, forKey: "isOnline")
                        CoreDataStack.shared.saveCdContext()
                }
            } catch {
                print(error)
            }
    }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.frc()
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
        CoreDataStack.shared.masterContext.perform {
        let result =  try! CoreDataStack.shared.masterContext.fetch(requestConvID)
            _ = Message.insertNewMessage(in: CoreDataStack.shared.masterContext, conversationID: result.first!.conversationID!, text: str!, recieveID: self.myPeerId.displayName, senderID: peerID.displayName, msgID: msgId!)
            try? CoreDataStack.shared.masterContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.tableView.reloadData()
        }
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
