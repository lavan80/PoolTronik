//
//  RelayTableViewCell.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 06/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation
import UIKit

protocol RelayTableViewCellDelegte : NSObjectProtocol {
    func detailsPressed(relayId: String)
    func actionButtonPressed(relayId: String)
    func scheduleButtonPressed(relayId: String)
}

class RelayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var onId: String?
    private var offId: String?
    private var status: Bool?
    
    let greenColor : UIColor = UIColor(red: 25.0/255.0, green: 168.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    let redColor : UIColor = UIColor(red: 224.0/255.0, green: 13.0/255.0, blue: 13.0/255.0, alpha: 1.0)
    
    weak var relayTableViewCellDelegte : RelayTableViewCellDelegte?
    
    override func awakeFromNib() {
        actionButton.layer.cornerRadius = 0.5 * actionButton.bounds.size.width
        actionButton.clipsToBounds = true
        actionButton.layer.borderWidth = 2
        actionButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func setCell(name: String, status: Bool, onId: String, offId: String)  {
        DispatchQueue.main.async {
            self.status = status
            self.onId = onId
            self.offId = offId
            self.nameLabel.text = name
            let color = status ? self.greenColor : self.redColor
            self.actionButton.backgroundColor = color
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        self.spinner.startAnimating()
        self.spinner.isHidden = false
        self.actionButton.backgroundColor = UIColor.black
        let statusId = status! ? offId : onId
        self.relayTableViewCellDelegte?.actionButtonPressed(relayId: statusId!)
    }
    
    @IBAction func detailsButtonPressed(_ sender: Any) {
        let statusId = status! ? offId : onId
        self.relayTableViewCellDelegte?.detailsPressed(relayId: statusId!)
    }
    @IBAction func schedualeButtonPressed(_ sender: Any) {
        let statusId = status! ? offId : onId
        self.relayTableViewCellDelegte?.scheduleButtonPressed(relayId: statusId!)
    }
}
