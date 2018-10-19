//
//  ViewController.swift
//  multipeer-conectivity
//
//  Created by Vincent Berihuete on 10/15/18.
//  Copyright © 2018 devcorerd. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {

    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var devicesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var data = [MCPeerID]()
    
//    let connectivityService = ConnectivityService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        ConnectivityConfigurator.shared.delegate = self
        ConnectivityConfigurator.shared.start()
        devicesLabel.text = UIDevice.current.name
    }

    @IBAction func doSomethingAction(_ sender: Any) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ConnectivityConfigurator.shared.end()
    }
}

extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = data[indexPath.row].displayName
        
        return cell
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let name = data[indexPath.row]
        ConnectivityConfigurator.shared.invite(peer: data[indexPath.row])
//        connectivityService.invite(peer: name)
    }
}

extension ViewController: ConnectivityConfiguratorDelegate{
    func browser(foundPeer: MCPeerID) {
        if data.filter({ (peer) -> Bool in
            return peer.displayName == foundPeer.displayName
        }).count == 0 {
            data.append(foundPeer)
            self.tableView.reloadData()
        }
    }
    
    func browser(lostPeer: MCPeerID) {
        self.data = data.filter({ (peer) -> Bool in
            return peer.displayName != lostPeer.displayName
        })
        self.tableView.reloadData()
    }
    
    func session(connectedPeers peers: [MCPeerID]) {
        Dispatch.main{
            self.connectedLabel.text = "\(peers.map{$0.displayName})"
        }
    }
}

