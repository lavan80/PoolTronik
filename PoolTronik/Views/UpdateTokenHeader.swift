//
//  UpdateTokenHeader.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 29/10/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation
import UIKit


protocol UpdateTokenHeaderDelegte : NSObjectProtocol {
    func updateTokenPressed()
}

class UpdateTokenHeader: UITableViewHeaderFooterView {
    
    weak var updateTokenHeaderDelegte : UpdateTokenHeaderDelegte?
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        self.updateTokenHeaderDelegte?.updateTokenPressed()
    }
}
