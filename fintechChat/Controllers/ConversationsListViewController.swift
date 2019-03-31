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

//    var conversationLists = [ConversationList]()
//    var conversationListsOnline = [ConversationList]()
//    var conversationListsHistory = [ConversationList]()
//    var conversationData = [ConversationList]()
//    var messageLists = [MessageLists]()
//    var messageListClass: MessageListClass!
    let coreDate = CoreDataStack()

    //let messageService = MultiPeerCommunicator()
    //слияние газпрома и роснефти прошло успешно
    //а евро тем временем в инвестициях = 72.55

    let messageServiceType = "tinkoff-chat"
    let discoveryInfo = ["userName": UIDevice.current.name + " DmitryPyatin"]
    var myPeerId: MCPeerID!
    var session: MCSession!
    var fromUserPeer: MCPeerID!

    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!
    
    
    var fetchedResultsController:NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
        let sortDescriptor = NSSortDescriptor(key: "isOnline", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack().mainContext, sectionNameKeyPath: "isOnline", cacheName: nil)
        return fetchedResultsController
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "isOnline", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDate.mainContext,  sectionNameKeyPath: "isOnline",
            cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        let conversation = frc.fetchedObjects
        
        print(conversation![0].recieveID)

        
        
        //messageService.delegate = self
        fetchedResultsController.delegate = self
        
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
        loadData()
    }

    deinit {
       serviceAdvertiser.stopAdvertisingPeer()
       serviceBrowser.stopBrowsingForPeers()
    }

    override func viewDidAppear(_ animated: Bool) {
        session.delegate = self
        navBarBtnSetup()
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerWillChangeContentcontrollerWillChangeContent")
        self.tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerDidChangeContent")
        self.tableView.endUpdates()
    }
}


extension ConversationsListViewController: UITableViewDelegate {
    //core data
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Online" : "History"
    }
//
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        } else {
            return 0
        }
    }
}

extension ConversationsListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        if indexPath.section == 0 {
//            conversationData = [conversationListsOnline[indexPath.row]]
//        } else {
//            conversationData = [conversationListsHistory[indexPath.row]]
//        }

        //_ = self.navigationController?.popToRootViewController(animated: true)
        //performSegue(withIdentifier: "showDetails", sender: self)
    }

    //подготовка данных для пересылки во вьюконтроллер
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConversationViewController {
            destination.session = session
            //destination.conversationData = conversationData
            //destination.messageLists = messageLists
            //destination.messageListClass = messageListClass
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //    return section == 0 ? conversationListsOnline.count : conversationListsHistory.count
        
        guard let sections = self.fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
        
        
//        if let sections = fetchedResultsController.sections {
//            print("fetchedResultsController.sections!!",sections[section].name)
//            return sections[section].numberOfObjects
//        } else {
//            return 0
//        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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
        
//        let conversation = fetchedResultsController.object(at: indexPath) as! Conversation
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = conversation.recieveID
//        cell.detailTextLabel?.text = conversation.conversationID
//        return cell
        
        //from lesson
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let conversation = self.fetchedResultsController.object(at: indexPath) as! Conversation
        cell.textLabel?.text = conversation.recieveID
        return cell
        
        
    }

    func loadData() {
        print(Thread.current)
//        conversationLists.removeAll()
//        conversationListsOnline.removeAll()
//        conversationListsHistory.removeAll()

        
//        do {
//            //try self.fetchedResultsController.performFetch()
//
//        } catch {
//            print(error)
//        }
        try! fetchedResultsController.performFetch()
        
        DispatchQueue.main.async {
            self.view.backgroundColor = ThemeManager.currentTheme().backgroundColor
            self.tableView.reloadData()
        }
 
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
    }

    override func viewWillAppear(_ animated: Bool) {
        do {
            //try fetchedResultsController.performFetch()
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        self.tableView.reloadData()
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
        print("нашли участника: \(peerID)")
        print("пригласили участника: \(peerID)")
        //зовем к себе

        //это пир кто к нам подключился
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    //кто то пропал
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("потеряли участника: \(peerID)")

//        if let index = conversationListsOnline.firstIndex(where: { $0.name == peerID.displayName }) {
//            conversationListsHistory.append(conversationListsOnline[index])
//            conversationListsOnline.remove(at: index)
//        }

        do {
            //try self.fetchedResultsController.performFetch()
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }

}

extension ConversationsListViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {

        //let indexHistory = conversationListsHistory.firstIndex(where: { $0.name == peerID.displayName })

        if state.rawValue == 2 {
            print("участник \(peerID) изменил состояние: \(state.rawValue)")
            fromUserPeer = peerID
            //добавим новый чат в коре дата
            coreDate.masterContext.perform {
                print("записываем данные!!!!!!!")
                //записываем данные
                //_ = AppUser.insertAppUser(in: self.coreDate.masterContext, name: text, timestamp: Date(), about: textAbout, image: imageData)
                _ = Conversation.insertNewConversation(in: self.coreDate.masterContext, recieveID: peerID.displayName, isOnline: true)
                try? self.coreDate.masterContext.save()
                //try! self.fetchedResultsController.performFetch()
                try! self.fetchedResultsController.performFetch()
                
            }
            

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
            print("Dispatch try! fetchedResultsController.performFetch()")
            //try! self.fetchedResultsController.performFetch()
            self.loadData()
            
//            DispatchQueue.main.async {
//
//                self.tableView.reloadData()
//            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let jsonDecoder = JSONDecoder()
        var str = ""
        do {
            let msg = try jsonDecoder.decode(MessageType.self, from: data)
            str = msg.text
        } catch let error {
            print(error)
        }
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
        DispatchQueue.main.async {
            //self.conversationListsOnline.sort(by: { $0.date!.compare($1.date!) == .orderedDescending })
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

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
