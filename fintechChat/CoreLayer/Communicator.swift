//
//  Communicator.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 19/03/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import Foundation
import MultipeerConnectivity
//во вью контролере работает кое-как. это кое-как надо сделать красиво через протокол

//protocol Communicator {
//    func sendMsg(msg: String, to userID: String, completionHandler: ((_ success: Bool, _ err: Error?) -> Void)?)
//
//    var delegate: CommunicatorDelegate? { get set }
//    var online: Bool { get set }
//}

protocol CommunicatorDelegate {
    //discovering
    func didFoundUser(userID: String, username: String?)
    func didLostUser(userID: String)
    //errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    //messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)

    func textChanged(manager: MultiPeerCommunicator, text: String)
}

class MultiPeerCommunicator: NSObject {
    //ура. счастье, осталось при переносе ничего не уронить, хотя где наша пропадала
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name + "DmitryPyatin")
    private let serType = "tinkoff-chat"
    private let servAdvert: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser

    var delegate: CommunicatorDelegate?

    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()

    override init() {
        self.servAdvert = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serType)

        super.init()

        self.servAdvert.delegate = self
        self.servAdvert.startAdvertisingPeer()

        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }

    deinit {
        self.servAdvert.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    func sendText(text: String) {
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(text.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch let error {
                print("Ошибка отправки: \(error)")
            }
        }
    }
}

extension MultiPeerCommunicator: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer: \(error)")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension MultiPeerCommunicator: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("didNotStartBrowsingForPeers: \(error)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("нашли участника: \(peerID)")
        print("пригласили участника: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("потеряли участника: \(peerID)")
    }

}

extension MultiPeerCommunicator: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("участник \(peerID) изменил состояние: \(state.rawValue)")

    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.textChanged(manager: self, text: str)
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
