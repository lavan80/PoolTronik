//
//  ScheduleTableViewCell.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 10/04/2020.
//  Copyright © 2020 Alexey Kozlov. All rights reserved.
//

import UIKit

protocol ScheduleTableViewCellDelegte : NSObjectProtocol {
    func deletePressed()
}


class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    
    weak var scheduleTableViewCellDelegte : ScheduleTableViewCellDelegte?
    
    @IBAction func deletePressed(_ sender: Any) {
        self.scheduleTableViewCellDelegte?.deletePressed()
    }
}
