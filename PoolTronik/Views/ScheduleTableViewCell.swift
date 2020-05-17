//
//  ScheduleTableViewCell.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 10/04/2020.
//  Copyright © 2020 Alexey Kozlov. All rights reserved.
//

import UIKit

protocol ScheduleTableViewCellDelegte : NSObjectProtocol {
    func deletePressed(relayId : Int)
}


class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    var relayId : Int?
    
    weak var scheduleTableViewCellDelegte : ScheduleTableViewCellDelegte?
    
    @IBAction func deletePressed(_ sender: Any) {
        self.deleteButton.isEnabled = false
        if let relayId = self.relayId {
            self.scheduleTableViewCellDelegte?.deletePressed(relayId: relayId)
        }
    }
}
