//
//  RelayDetailsViewController.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 06/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation
import UIKit

class RelayDetailsViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerStatusView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var relayStatusView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var relayStatusButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    let greenColor : UIColor = UIColor(red: 25.0/255.0, green: 168.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    let redColor : UIColor = UIColor(red: 224.0/255.0, green: 13.0/255.0, blue: 13.0/255.0, alpha: 1.0)
    var relay: Relay?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.relay = sender as? Relay
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner.isHidden = true
        headerStatusView.layer.cornerRadius = 0.5 * headerStatusView.bounds.size.width
        headerStatusView.clipsToBounds = true
        relayStatusView.layer.cornerRadius = 0.5 * relayStatusView.bounds.size.width
        relayStatusView.clipsToBounds = true
        if let relay = self.relay
        {
            setView(relay: relay)
        }
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    fileprivate func setView(relay :Relay)
    {
        self.headerLabel.text = relay.name
        let color = relay.status ? self.greenColor : self.redColor
        self.headerStatusView.backgroundColor = color
        self.relayStatusButton.backgroundColor = color
    }
    
    fileprivate func changeStatus(relay: Relay)
    {
        let relayId = relay.status ? relay.offId : relay.onId
        LocalDataBase.shared.changeStatus(key: relayId, completion: {(suc) in
            self.relay?.status = !relay.status
            let color = (self.relay?.status)! ? self.greenColor : self.redColor
            self.relayStatusButton.backgroundColor = color
            self.headerStatusView.backgroundColor = color
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
        })
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.headerLabel.text = textField.text
    }
    
    @IBAction func relayStatusButtonPressed(_ sender: Any) {
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        if let relay = self.relay
        {
            self.changeStatus(relay: relay)
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if nameTextField.text != nil && (nameTextField.text?.count)! > 0
        {
            LocalDataBase.shared.setName(key: (relay?.onId)!, name: self.nameTextField.text ?? (relay?.name)!, completion: {(suc) in
                self.navigationController?.popViewController(animated: true)
            })
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}


