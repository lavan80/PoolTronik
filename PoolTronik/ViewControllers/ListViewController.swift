//
//  ListViewController.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 06/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let numberOfRelays : Int = 8
    fileprivate var relayArray : [Relay]?
    private var showHeader : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("TokenUpdateSent"), object: nil)
        //show token update needed on first launch
        if  UserDefaults.standard.value(forKey: "keyNotificationToken") == nil {
            self.showHeader = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
        self.title = "PoolTronik"
    }
    
    private func setTableView() {
        tableView.tableFooterView = UIView()
        let headerNib = UINib.init(nibName: "UpdateTokenHeader", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "UpdateTokenHeader")
    }
    
    fileprivate func loadData() {
        self.relayArray = LocalDataBase.shared.getRelayArray()
        self.tableView.reloadData()
    }
    
    @objc func methodOfReceivedNotification(notification: NSNotification){
        let succsess = notification.userInfo?["succsess"] as? Bool
        self.showHeader = !(succsess ?? true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func sideMenuPressed(_ sender: Any) {
        if let sideMenuController = sideMenuController
        {
            if sideMenuController.isMenuRevealed
            {
                sideMenuController.hideMenu()
            }
            else
            {
                sideMenuController.revealMenu()
            }
        }
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.relayArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "relayCell", for: indexPath) as! RelayTableViewCell
        cell.relayTableViewCellDelegte = self
        if let relay  = self.relayArray?[indexPath.row]
        {
            cell.setCell(name: relay.name, status: relay.status, onId: relay.onId, offId: relay.offId)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if showHeader {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "UpdateTokenHeader") as! UpdateTokenHeader
            headerView.updateTokenHeaderDelegte = self
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return showHeader ? 150 : 0
    }
}

extension ListViewController: RelayTableViewCellDelegte {
    func actionButtonPressed(relayId: String) {
        NetworkManager.shared.setStatus(key: relayId) { (succsess, key) in
            if succsess {
                LocalDataBase.shared.changeStatus(key: key, completion: {(suc) in
                    DispatchQueue.main.async {
                        self.loadData()
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    self.loadData()
                }
            }
        }
    }
    
    func detailsPressed(relayId: String) {
        let relay = LocalDataBase.shared.getRelay(relayId: relayId)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let relayDetailsViewController = storyBoard.instantiateViewController(withIdentifier: "relayDetailsViewController") as! RelayDetailsViewController
        relayDetailsViewController.relay = relay
        self.navigationController?.pushViewController(relayDetailsViewController, animated: true)
    }
}

extension ListViewController: UpdateTokenHeaderDelegte {
    func updateTokenPressed() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsViewController = storyBoard.instantiateViewController(withIdentifier: "settingsViewController") as! SettingsViewController
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .fullScreen
        sideMenuController?.present(navigationController, animated: true, completion: nil)
    }
}

