//
//  ConversationViewController.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 23/02/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConversationViewController: UIViewController, UITextFieldDelegate {

    
//    var conversationLists = [ConversationList]()
//    var conversationListsOnline = [ConversationList]()
//    var conversationListsHistory = [ConversationList]()
    var conversationData = [ConversationList]()
    var messageLists = [MessageLists]()
    var messageListClass: MessageListClass!
    var session: MCSession!
    
    @IBOutlet weak var messageTxtField: UITextField!
    @IBOutlet weak var sendMessageBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        self.navigationItem.title = conversationData[0].peerID.displayName
        session.delegate = self
        messageTxtField.delegate = self
        self.view.backgroundColor = ThemeManager.currentTheme().backgroundColor
        self.tableView.backgroundColor = ThemeManager.currentTheme().backgroundColor
        keyboardSetup()
    }

    @IBAction func sendMsgActionBtn(_ sender: UIButton) {
        if (messageTxtField.text?.count)! > 0 {
            
            //добавим сообщение в массив
            addDataToArrayMsg(text: messageTxtField.text!, fromUser: conversationData[0].peerID.displayName, toUser: session.myPeerID.displayName)
            //отошлем пиру
            sendText(text: messageTxtField.text!, peerID: conversationData[0].peerID)
            messageTxtField.resignFirstResponder()
            updateTable()
        }
    }
    
    func updateTable(){
        tableView.reloadData()
        if self.messageLists.count != 0 {
            let indexPath = IndexPath(row: self.messageLists.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}


extension ConversationViewController: UITableViewDelegate {
}

extension ConversationViewController: UITableViewDataSource , MCSessionDelegate  {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        var str = ""
        let jsonDecode = JSONDecoder()
        do {
             let msg = try jsonDecode.decode(Message.self, from: data)
             str = msg.text
        } catch {
            print("can not encode data")
        }
           DispatchQueue.main.async {
                self.addDataToArrayMsg(text: str, fromUser: self.conversationData[0].peerID.displayName, toUser: self.session.myPeerID.displayName)
                    self.updateTable()
            }
    }
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print(#function)
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

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        
        if (messageLists[indexPath.row].toUser == session.myPeerID.displayName ) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MessageTableViewCell
            let text = messageLists[indexPath.row].text
            cell.messageText.text = text
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
            let text = messageLists[indexPath.row].text
            cell.messageText.text = text
            return cell
        }
    }
    
 
    func addDataToArrayMsg(text: String, fromUser: String, toUser: String){
        //добавим сообщение в массив
        let item = MessageLists(text: text,fromUser: fromUser, toUser: toUser )
        messageLists.append(item)
    }
    
    
    func sendText(text: String, peerID: MCPeerID) {
        print(text)
        if session.connectedPeers.count > 0 {
            print("УРА УРА УРА что-то пошло ")
            let jsonEncoder = JSONEncoder()
            let msg = Message(text: text)
            let jsonMessage = try? jsonEncoder.encode(msg)
            
            do {
                try self.session.send(jsonMessage!, toPeers: [peerID], with: .reliable)
            }
            catch let error {
                print("Ошибка отправки: \(error)")
            }
        }
    }
    
    func keyboardSetup() {
        // Keyboard notifications:
        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillShowNotification, object: nil, queue: nil) { (nc) in

            self.view.frame.origin.y = -350
            }
        
    
        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillHideNotification, object: nil, queue: nil) { (nc) in
            self.view.frame.origin.y = 0.0
        }
    }
    
    // скроем клавиатуру при нажатии на энтер
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n"
        {
            sendMsgActionBtn(sendMessageBtn)
            messageTxtField.resignFirstResponder()
            return true
        }
        return true
    }
    
    
    
}





//MARK: ЛУКЬЯНЕНКО - ЧЕРНОВИК
    
//    //подготовка данных для пересылки во вьюконтроллер
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? ConversationListViewController {
//            destination.messageLists = messageLists
//        }
//    }
    
    
    
         /*   func loadMessage() {

        let item = MessageLists(text: "привет",fromUser: "Вася",toUser: "Петя" )
        let item1 = MessageLists(text: "привет",fromUser: "Вася1",toUser: "Петя1" )
        let item2 = MessageLists(text: "как дела?",fromUser: "Вася2",toUser: "Петя2" )
        let item3 = MessageLists(text: "отлично. делаю домашку",fromUser: "Вася3",toUser: "Петя3" )
        let item4 = MessageLists(text: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.",fromUser: "Вася5",toUser: "Петя5")
        let item5 = MessageLists(text: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.",fromUser: "Вася4",toUser: "Петя4" )
        messageLists.append(item)
        messageLists.append(item1)
        messageLists.append(item2)
        messageLists.append(item3)
        messageLists.append(item4)
        messageLists.append(item5)

    }    */
