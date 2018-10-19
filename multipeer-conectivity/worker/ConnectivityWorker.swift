//
//  ConnectivityWorker.swift
//  multipeer-conectivity
//
//  Created by Vincent Berihuete on 10/18/18.
//  Copyright © 2018 devcorerd. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ConnectivityWorker: NSObject{
    
    private var serviceAdvertiser : MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    var delegate: ConnectivityWorkerDelegate?
    
    func start(withPeerId peerId: MCPeerID, serviceType: String) {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        self.serviceAdvertiser?.delegate = self
        self.serviceAdvertiser?.startAdvertisingPeer()
        self.serviceBrowser?.delegate = self
        self.serviceBrowser?.startBrowsingForPeers()
    }
    
    func end(){
        self.serviceAdvertiser?.stopAdvertisingPeer()
        self.serviceBrowser?.stopBrowsingForPeers()
    }
    
    deinit {
        end()
    }
    
    
    /// Invites a peerId into a session
    ///
    /// - Parameters:
    ///   - peerId: The peerId of the invited device
    ///   - session: The session to be invited to
    ///   - timeout: The amont of seconds for the invitation to timeout; default value is 20
    func invite(peer peerId: MCPeerID, into session: MCSession, with timeout: TimeInterval = 20){
        self.serviceBrowser?.invitePeer(peerId, to: session, withContext: nil, timeout: timeout)
    }
}


extension ConnectivityWorker: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
//        print("Device: \(myPeerId.displayName) did not start advertising")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        print("Device: \(myPeerId.displayName) did receive an invitation from \(peerID.displayName)")
//        guard let session = self.delegate?.providedSession else{
//            return
//        }
//        invitationHandler(true, session)
        delegate?.handle(invitation: invitationHandler, withData: context)
    }
}

extension ConnectivityWorker: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        print("Device: \(myPeerId.displayName) found \(peerID.displayName)")
        delegate?.browser(foundPeer: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        print("Device: \(myPeerId.displayName) lost connection with \(peerID.displayName)")
        delegate?.browser(lostPeer: peerID)
//        delegate?.session(connectedPeers: session.connectedPeers)
    }
    
}

protocol ConnectivityWorkerDelegate {
//    func handle(invitation: @escaping (Bool, MCSession?) -> (), withData data: Data?)
    func handle(invitation: @escaping (Bool, MCSession?) -> (), withData data: Data?)
    func browser(foundPeer: MCPeerID)
    func browser(lostPeer: MCPeerID)
}
