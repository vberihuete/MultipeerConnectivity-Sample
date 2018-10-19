//
//  ConnectivityConfigurator.swift
//  multipeer-conectivity
//
//  Created by Vincent Berihuete on 10/18/18.
//  Copyright © 2018 devcorerd. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ConnectivityConfigurator: NSObject{
    
    static let shared = ConnectivityConfigurator()
    
    private lazy var worker : ConnectivityWorker = {
        let worker = ConnectivityWorker()
        worker.delegate = self
        return worker
    }()
    
    var delegate: ConnectivityConfiguratorDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    
    /// construct peer id based on device type (iPad or iPhone) and the business acronym
    let myPeerId: MCPeerID = MCPeerID(displayName: "\(UIDevice.current.userInterfaceIdiom.rawValue)-\(UIDevice.current.identifierForVendor!)-JEFES") /*{
        // TODO: bring from the userDefaults
        let acronym = "JEFES"
        // TODO: bring from the userDefaults
        let userId = UIDevice.current.identifierForVendor!
        return MCPeerID(displayName: "\(UIDevice.current.userInterfaceIdiom.rawValue)-\(userId)-\(acronym)")
    }*/
    
    var serviceType: String{
        // TODO: bring from the userDefaults
        return "dev-type"
    }
    
    
    /// Starts the monitoring for connections
    func start() {
        self.worker.start(withPeerId: self.myPeerId, serviceType: self.serviceType)
    }
    
    /// Ends the monitoring for connections
    func end(){
        self.worker.end()
    }
    
    
    /// Invites a peerId into a session
    func invite(peer peerId: MCPeerID, with timeout: TimeInterval = 20){
        self.worker.invite(peer: peerId, into: self.session, with: timeout)
    }
}


extension ConnectivityConfigurator: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
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

extension ConnectivityConfigurator: ConnectivityWorkerDelegate{
    
    func handle(invitation: @escaping (Bool, MCSession?) -> (), withData data: Data?) {
        // TODO: validate device invitation to connect
        invitation(true, self.session)
    }
    
    func browser(foundPeer: MCPeerID) {
        delegate?.browser(foundPeer: foundPeer)
    }
    
    func browser(lostPeer: MCPeerID) {
        delegate?.browser(lostPeer: lostPeer)
    }
    
    
}

protocol ConnectivityConfiguratorDelegate {
    func browser(foundPeer: MCPeerID)
    func browser(lostPeer: MCPeerID)
    func session(connectedPeers peers: [MCPeerID])
}
