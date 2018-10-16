//
//  ConnectivityService.swift
//  multipeer-conectivity
//
//  Created by Vincent Berihuete on 10/15/18.
//  Copyright © 2018 devcorerd. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ConnectivityService: NSObject{
    
    private let type = "example-type"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    var delegate : ConnectivityServiceDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: type)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: type)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func invite(peer peerId: MCPeerID){
//        let peerId = MCPeerID(displayName: name)
        self.serviceBrowser.invitePeer(peerId, to: self.session, withContext: nil, timeout: 10)
    }
    
}

extension ConnectivityService: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Device: \(myPeerId.displayName) did not start advertising")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Device: \(myPeerId.displayName) did receive an invitation from \(peerID.displayName)")
        invitationHandler(true, self.session)
    }
}

extension ConnectivityService: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Device: \(myPeerId.displayName) found \(peerID.displayName)")
        delegate?.browser(foundPeer: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Device: \(myPeerId.displayName) lost connection with \(peerID.displayName)")
        delegate?.browser(lostPeer: peerID)
        delegate?.session(connectedPeers: session.connectedPeers)
    }
    
}

extension ConnectivityService: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(self.myPeerId.displayName) - Session did change it has connected \(session.connectedPeers.map{$0.displayName})")
        delegate?.session(connectedPeers: session.connectedPeers)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("did received data \(data) from peer: \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}

protocol ConnectivityServiceDelegate {
    func browser(foundPeer: MCPeerID)
    func browser(lostPeer: MCPeerID)
    func session(connectedPeers peers: [MCPeerID])
}
