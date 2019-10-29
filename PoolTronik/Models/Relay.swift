//
//  Relay.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 06/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation

class Relay: NSObject, NSCoding {
    var name: String
    var status: Bool
    var onId: String
    var offId: String
    
    init(name: String, status: Bool, onId: String, offId: String) {
        self.name = name
        self.status = status
        self.onId = onId
        self.offId = offId
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name")
        let status = aDecoder.decodeBool(forKey: "status")
        let onId = aDecoder.decodeObject(forKey: "onId") as! String
        let offId = aDecoder.decodeObject(forKey: "offId") as! String
        self.init(name: name as! String, status: status, onId: onId, offId: offId)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(onId, forKey: "onId")
        aCoder.encode(offId, forKey: "offId")
    }
}
