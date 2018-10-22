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
    
    let LAST_INVITED: String = "last-invited-peer"
    let LAST_INVITED_DATA: String = "last-invited-communication"
    
    var foundPeers: [MCPeerID] = []
    
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
    func invite(peer peerId: MCPeerID, using data: Communication? = nil, with timeout: TimeInterval = 20){
        self.worker.invite(peer: peerId, into: self.session, using: data, with: timeout)
        UserDefaults.standard.set(peerId.displayName, forKey: LAST_INVITED)
        UserDefaults.standard.set(self.encode(data), forKey: LAST_INVITED_DATA)
    }
    
    /// Encodes the given data and if it throws an error it will return an empty data pb
    ///
    /// - Parameter data: The object that uses type Codable
    /// - Returns: The data object
    func encode<T: Codable>(_ data: T) -> Data{
       return self.worker.encode(data)
    }
    
    /// Decodes the given data based on the expected type
    ///
    /// - Parameter data: The data
    /// - Returns: The parsed date if the decoder was able to decode
    func decode<T: Codable>(_ data: Data) -> T?{
        return self.worker.decode(data)
    }
    
    
    /// This variable says if the device is engaged to the last one he tried to.
    var engaged: Bool{
        guard let lastInvited = self.lastInvited else {
            return false
        }
        guard session.connectedPeers.contains(where: { (peerId) -> Bool in
             peerId.displayName == lastInvited
             }) else{
                return false
        }
        
        return true
    }
    
    
    /// This variable says the MCPeerID.displayName of the last iPad issued to connect
    var lastInvited: String?{
        return UserDefaults.standard.value(forKey: LAST_INVITED) as? String
    }
    
    
    
    /// Tries to engage the iphone to the last isued ipad
    /// providing in a callback whether it succesed or not
    /// - Parameter callback: This is a clousure that provides a parameter saying whether it send the engament succesfully or not
    func engage(callback: @escaping (Bool) -> () = {_ in }){
        guard let lastInvited = self.lastInvited, let peerID = foundPeers.filter({ (peerID) -> Bool in
            return peerID.displayName == lastInvited
        }).first, let data = UserDefaults.standard.value(forKey: LAST_INVITED_DATA) as? Data, let communication: Communication = self.decode(data) else {
            callback(false)
            return
        }
        if lastInvited == peerID.displayName, !engaged{
                Dispatch.main(delay: 4) {
                    self.invite(peer: peerID, using: communication)
                    callback(true)
                }
        }
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
        Dispatch.async {
            guard let data = data, let communication: Communication = self.decode(data), communication.type == .join else{
                // TODO:  remove
                print("Session rejected because no credentials were sent")
                invitation(false, self.session)
                return
            }
            
            guard communication.origin == .phone, UIDevice.current.userInterfaceIdiom == .pad else{
                print("Session rejected because only phones can request connections and they can only be directed to an ipad")
                invitation(false, self.session)
                return
            }
            
            print("here's the parsed data")
            if let data: [String] = self.decode(communication.data) {
                //TODO: Validate user data
                print(data)
            }
            print("End of the parsed data")
            invitation(true, self.session)
        }
    }
    
    func browser(foundPeer: MCPeerID) {
        delegate?.browser(foundPeer: foundPeer)
        if foundPeers.filter({ (peer) -> Bool in
            return peer.displayName == foundPeer.displayName
        }).count == 0 {
            foundPeers.append(foundPeer)
        }
        print("Found peer: \(foundPeer.displayName)")
        guard !engaged else {
            return
        }
        self.engage()
    }
    
    func browser(lostPeer: MCPeerID) {
        delegate?.browser(lostPeer: lostPeer)
        self.foundPeers = foundPeers.filter({ (peer) -> Bool in
            return peer.displayName != lostPeer.displayName
        })
    }
    
    
}

protocol ConnectivityConfiguratorDelegate {
    func browser(foundPeer: MCPeerID)
    func browser(lostPeer: MCPeerID)
    func session(connectedPeers peers: [MCPeerID])
}
