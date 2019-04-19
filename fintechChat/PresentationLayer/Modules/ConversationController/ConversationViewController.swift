//
//  ConversationViewController.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 23/02/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData

class ConversationViewController: UIViewController, UITextFieldDelegate,  NSFetchedResultsControllerDelegate {

    var conversation: Conversation?
    var message: Message?
    var session: MCSession!
    var peerID: MCPeerID!

    var fetchedResultsController = CoreDataStack.fetchedResultsController(entityName: "Message", keyForSort: "timestamp", sectionName: nil)
    
    //var fetchedResultsController = CoreDataStack.fetchedResultsController(entityName: "Conversation", keyForSort: "isOnline", sectionName: "isOnline", predicate: nil, id: nil)

    @IBOutlet weak var messageTxtField: UITextField!
    @IBOutlet weak var sendMessageBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reading object
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        fetchedResultsController.delegate = self
        frc()
        
        
        self.navigationItem.title = conversation?.userid
        
        UIView.animate(withDuration: 0.5) {
            self.navigationItem.title = self.conversation?.userid
            self.navigationItem.titleView?.backgroundColor = .green
            }
        
       
        session.delegate = self
        messageTxtField.delegate = self
        self.view.backgroundColor = ThemeManager.currentTheme().backgroundColor
        self.tableView.backgroundColor = ThemeManager.currentTheme().backgroundColor
        keyboardSetup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func frc() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        moveMesageToFirst()
    }

    @IBAction func sendMsgActionBtn(_ sender: UIButton) {
        if (messageTxtField.text?.count)! > 0 {

            self.addDataToArrayMsg(text: messageTxtField.text!, fromUser: session.myPeerID.displayName, toUser: self.conversation?.userid ?? "")
            //отошлем пиру
            if peerID != nil {
                self.sendText(text: messageTxtField.text!, peerID: peerID)
            } else {
                let alertController = UIAlertController(title: "DER KATASTROFA", message: "PEER OTVALIL", preferredStyle: .alert)
                let actionSave = UIAlertAction(title: "ОК", style: .default) { (_) in
                }
                alertController.addAction(actionSave)
                self.present(alertController, animated: true, completion: nil)
            }
            messageTxtField.resignFirstResponder()
            updateTable()
        }
    }

    func updateTable() {
        tableView.reloadData()
        moveMesageToFirst()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField.text!.count > 1 {
//            sendMessageBtn.changeColor(sendMessageBtn, state: true)
//        }
        print(#function)
    }
    
    func moveMesageToFirst() {
        let requestMess = FetchRequestManager.shared.fetchMesasgeWithConversationID(id: conversation!.conversationID!)
        do {
            let result =  try CoreDataStack.shared.mainContext.fetch(requestMess)
            if result.count != 0 {
                let indexPath = IndexPath(row: result.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } catch {
            print("error")
        }
    }
}


extension ConversationViewController: UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let sections = fetchedResultsController.sections {
//            return sections[section].numberOfObjects
//        } else {
//            return 0
//        }
        
        let requestMess = FetchRequestManager.shared.fetchMesasgeWithConversationID(id: conversation!.conversationID!)
        do {
            let result =  try CoreDataStack.shared.mainContext.fetch(requestMess)
            return result.count
        } catch {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let messages = fetchedResultsController.object(at: indexPath) as! Message

        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MessageTableViewCell
        let requestMess = FetchRequestManager.shared.fetchMesasgeWithConversationID(id: conversation!.conversationID!)
        
            do {
                let result =  try CoreDataStack.shared.mainContext.fetch(requestMess)
                
                if result.count > 0 {
                    //есть сообщения
                    if result[indexPath.row].senderID == conversation?.userid {
                                let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MessageTableViewCell
                        cell.messageText.text = " " + result[indexPath.row].text!
                        return cell
                    } else {
                                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
                        cell.messageText.text = "  " + result[indexPath.row].text!
                        return cell
                    }
                }

            } catch {
                print(error)
            }
        return UITableViewCell()
    }
    
    
}


extension ConversationViewController: UITableViewDelegate {
    //core data
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Messages" //section == 0 ? "Online" : "History"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = self.fetchedResultsController.sections {
            return sections.count
        } else {
            return 0
        }
    }
}

extension ConversationViewController: MCSessionDelegate {
   
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
            
            _ = Message.insertNewMessage(in: CoreDataStack.shared.masterContext, conversationID: result.first!.conversationID!, text: str!, recieveID: session.myPeerID.displayName, senderID: peerID.displayName, msgID: msgId!)
            try? CoreDataStack.shared.masterContext.save()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.moveMesageToFirst()
        }
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print(#function, state.rawValue)
        //немного другая логика. набрать текст можно, но если пира нет отправить его нельзя
        //для проверки свернуть/развернуть второе приложение
        DispatchQueue.main.async {
            if state.rawValue == 0 {
                self.sendMessageBtn.changeColor(self.sendMessageBtn, state: false)
            } else if state.rawValue == 2 {
                self.sendMessageBtn.changeColor(self.sendMessageBtn, state: true)
            }
        }

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print(#function)
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print(#function)
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print(#function)
    }
    
    
    //кто то пропал
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        print("потеряли участника: \(peerID)")
//        let lostUserConnect = FetchRequestManager.shared.fetchConversationWithID(id: peerID.displayName)
//
//        do {
//            let result =  try CoreDataStack.shared.mainContext.fetch(lostUserConnect)
//            let objectUpdate = result[0]
//            objectUpdate.setValue(false, forKey: "isOnline")
//            CoreDataStack.shared.saveCdContext()
//        }  catch {
//            print("error")
//        }
        sendMessageBtn.changeColor(sendMessageBtn, state: false)
    }

    func addDataToArrayMsg(text: String, fromUser: String, toUser: String) {
        //добавим сообщение в core data
//задваивал
//        var msgId: String?
//        print("try save didReceiveData", self.conversation!.conversationID!)
//        let msg = MessageType(text: text)
//        msgId = msg.messageId
//
//        _ = Message.insertNewMessage(in: CoreDataStack.shared.mainContext, conversationID: self.conversation!.conversationID!, text: text+"2", recieveID: fromUser, senderID: toUser, msgID: msgId!)
//            CoreDataStack.shared.saveCdContext()
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
//            self.tableView.reloadData()
//        }
    }

    // MARK: отправим сообщение Пиру
    func sendText(text: String, peerID: MCPeerID) {
        if session.connectedPeers.count > 0 {
            print("УРА УРА УРА что-то пошло ")
            let jsonEncoder = JSONEncoder()
            let msg = MessageType(text: text)
            var msgId: String?
            msgId = msg.messageId
            let jsonMessage = try? jsonEncoder.encode(msg)

            do {
                try self.session.send(jsonMessage!, toPeers: [peerID], with: .reliable)
            } catch let error {
                print("Ошибка отправки: \(error)")
            }
            
            let requestConvID: NSFetchRequest<Conversation> = Conversation.fetchRequest()
            requestConvID.predicate = NSPredicate(format: "userid == %@", peerID.displayName)
            CoreDataStack.shared.masterContext.perform {
                let result =  try! CoreDataStack.shared.masterContext.fetch(requestConvID)
                
                _ = Message.insertNewMessage(in: CoreDataStack.shared.masterContext, conversationID: result.first!.conversationID!, text: text, recieveID: peerID.displayName, senderID: self.session.myPeerID.displayName, msgID: msgId!)
                try? CoreDataStack.shared.masterContext.save()
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.moveMesageToFirst()
            }
        }
        
    }

    func keyboardSetup() {
        // Keyboard notifications:
        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillShowNotification, object: nil, queue: nil) { (_) in 
            self.view.frame.origin.y = -350
            }

        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillHideNotification, object: nil, queue: nil) { (_) in
            self.view.frame.origin.y = 0.0
        }
    }

    // скроем клавиатуру при нажатии на энтер
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            sendMsgActionBtn(sendMessageBtn)
            messageTxtField.resignFirstResponder()
            return true
        }
        return true
    }
}
