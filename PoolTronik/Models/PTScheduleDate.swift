//
//  PTScheduleDate.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 10/04/2020.
//  Copyright © 2020 Alexey Kozlov. All rights reserved.
//

import Foundation

class PTScheduleDate: NSObject, Codable {
    var id : Int?
    var relay : Int?
    var status : Int?
    var startDate : String?
    var nextDates : [String]? = []
    var duration : Int = 0
    var iteration : Int?
    var repeatList : [Int]? = []
    
    init(id: Int, relay: Int, status: Int, startDate: String, nextDates: [String], duration: Int, iteration: Int, repeatList: [Int]) {
        self.id = id
        self.relay = relay
        self.status = status
        self.startDate = startDate
        self.nextDates = nextDates
        self.duration = duration
        self.iteration = iteration
        self.repeatList = repeatList
    }
    
//    required convenience init(coder aDecoder: NSCoder) {
//        let id = aDecoder.decodeObject(forKey: "id") as! Int
//        let relay = aDecoder.decodeObject(forKey: "relay") as! Int
//        let status = aDecoder.decodeObject(forKey: "status") as! Int
//        let startDate = aDecoder.decodeObject(forKey: "startDate") as! String
//        let nextDates = aDecoder.decodeObject(forKey: "nextDates")  as! [String]
//        let duration = aDecoder.decodeObject(forKey: "duration") as! Int
//        let iteration = aDecoder.decodeObject(forKey: "iteration") as! Int
//        let repeatList = aDecoder.decodeObject(forKey: "repeatList") as! [Int]
//        self.init(id: id, relay: relay, status: status, startDate: startDate, nextDates: nextDates, duration: duration, iteration: iteration, repeatList: repeatList)
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(id, forKey: "id")
//        aCoder.encode(relay, forKey: "relay")
//        aCoder.encode(status, forKey: "status")
//        aCoder.encode(startDate, forKey: "startDate")
//        aCoder.encode(nextDates, forKey: "nextDates")
//        aCoder.encode(duration, forKey: "duration")
//        aCoder.encode(iteration, forKey: "iteration")
//        aCoder.encode(repeatList, forKey: "repeatList")
//    }
}
