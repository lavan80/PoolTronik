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
    @IBOutlet weak var tableView: UITableView!
    
    let greenColor : UIColor = UIColor(red: 25.0/255.0, green: 168.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    let redColor : UIColor = UIColor(red: 224.0/255.0, green: 13.0/255.0, blue: 13.0/255.0, alpha: 1.0)
    var relay: Relay?
    var schedualedTasks : [PTScheduleDate] = []
    
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
        let relayArray = LocalDataBase.shared.getRelayArray()
        if let relay = self.relay
        {
            setView(relay: relay)
            if let index = relayArray.index(where: { $0.onId == self.relay?.onId }) {
                self.getSchedule(relay: index)
            }
        }
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.navigationController?.navigationBar.topItem?.title = " "
        tableView.tableFooterView = UIView()
    }
    
    private func getSchedule(relay: Int) {
        NetworkManager.shared.getScheduale(relay: relay) {[weak self] (succsess, pTScheduales) in
            if succsess {
                self?.schedualedTasks = pTScheduales
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            else {
                let alert = UIAlertController(title: "Failed to get schedule", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
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
    
    @IBAction func scheduleButtonPressed(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let scheduleViewController = storyBoard.instantiateViewController(withIdentifier: "ScheduleViewController") as! ScheduleViewController
        scheduleViewController.relay = self.relay
        self.navigationController?.pushViewController(scheduleViewController, animated: true)
    }
}

extension RelayDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.schedualedTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ptSchedule = self.schedualedTasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell
        cell.nameLabel.text = relay?.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let date = dateFormatter.date(from:ptSchedule.startDate!)!
        dateFormatter.dateFormat = "EE HH:mm"
        let weekDay = dateFormatter.string(from: date)
        let once = ptSchedule.duration == 0 ? "    Constantly" : "    Once"
        let off = ptSchedule.status == 0 ? " (on)" : " (off)"
        cell.scheduleLabel.text = weekDay + once + off
        cell.scheduleTableViewCellDelegte = self
        cell.relayId = ptSchedule.id
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension RelayDetailsViewController : ScheduleTableViewCellDelegte {
    func deletePressed(relayId : Int) {
        NetworkManager.shared.deleteSchedule(relayId: relayId) {[weak self] (succsess) in
            if succsess {
                self?.schedualedTasks = (self?.schedualedTasks.filter {$0.id != relayId})!
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            else {
                if let index = self?.schedualedTasks.index(where: { $0.id == relayId }) {
                    let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ScheduleTableViewCell
                    DispatchQueue.main.async {
                        cell?.deleteButton.isEnabled = true
                    }
                }
                let alert = UIAlertController(title: "Failed to delete schedule", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async {
                     self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
