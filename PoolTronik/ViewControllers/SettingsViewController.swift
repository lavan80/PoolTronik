//
//  SettingsViewController.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 06/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var serverIpTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTextfields()
    }
    
    private func setTextfields() {
        let ip = NetworkManager.shared.getIp()
        let serverIP = NetworkManager.shared.getIp()
        ipTextField.placeholder =  String(format: "Your current IP is %@", ip)
        serverIpTextField.placeholder =  String(format: "Your current IP is %@", serverIP)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        LocalDataBase.shared.resetDataBase()
    }
    
    @IBAction func changeIpPressed(_ sender: Any) {
        if let newIP = self.ipTextField.text, newIP.validateIpAddress() {
            NetworkManager.shared.setIP(ip: newIP)
            self.ipTextField.text = ""
            self.ipTextField.resignFirstResponder()
            let ip = NetworkManager.shared.getIp()
            ipTextField.placeholder =  String(format: "Your current IP is %@", ip)
        }
    }
    
    @IBAction func changeServerIpPressed(_ sender: Any) {
        if let newServerIP = self.serverIpTextField.text, newServerIP.validateIpAddress() {
            NetworkManager.shared.setServerIP(ip: newServerIP)
            self.serverIpTextField.text = ""
            self.serverIpTextField.resignFirstResponder()
            let serverIp = NetworkManager.shared.getServerIp()
            serverIpTextField.placeholder =  String(format: "Your current IP is %@", serverIp)
        }
    }
    
    @IBAction func updatePressed(_ sender: Any) {
        NetworkManager.shared.updateToken(token: UserDefaults.standard.value(forKey: "keyNotificationToken") as? String ?? "") { (succsess) in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: succsess ? "Token updated" : "Failed to update token", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let userInfo = ["succsess": succsess]
            NotificationCenter.default.post(name: Notification.Name("TokenUpdateSent"), object: nil, userInfo: userInfo)
        }
    }
}
