//
//  LocalDataBase.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 06/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation

class LocalDataBase {
    
    let keyRelay1 : String = "FF0101"
    let keyRelay2 : String = "FF0201"
    let keyRelay3 : String = "FF0301"
    let keyRelay4 : String = "FF0401"
    let keyRelay5 : String = "FF0501"
    let keyRelay6 : String = "FF0601"
    let keyRelay7 : String = "FF0701"
    let keyRelay8 : String = "FF0801"
    
    let keyRelayArray : String = "keyRelayArray"
    let keyDataBaseInitialized : String = "keyDataBaseInitialized"
    
    public static let shared : LocalDataBase = LocalDataBase()
    
    func initRelayArray() {
        let defaults = UserDefaults.standard
        var relayArray : [Relay] = []
        if (defaults.bool(forKey: keyDataBaseInitialized) == false) {
            let relay1 : Relay = Relay(name: "Relay1", status: false, onId: "FF0101", offId: "FF0100")
            relayArray.append(relay1)
            //defaults.set(relay1, forKey: keyRelay1)
            let relay2 : Relay = Relay(name: "Relay2", status: false, onId: "FF0201", offId: "FF0200")
            relayArray.append(relay2)
            //defaults.set(relay2, forKey: keyRelay2)
            let relay3 : Relay = Relay(name: "Relay3", status: false, onId: "FF0301", offId: "FF0300")
            relayArray.append(relay3)
            //defaults.set(relay3, forKey: keyRelay3)
            let relay4 : Relay = Relay(name: "Relay4", status: false, onId: "FF0401", offId: "FF0400")
            relayArray.append(relay4)
            //defaults.set(relay4, forKey: keyRelay4)
            /*let relay5 : Relay = Relay(name: "Relay5", status: false, onId: "FF0501", offId: "FF0500")
            relayArray.append(relay5)
            //defaults.set(relay5, forKey: keyRelay5)
            let relay6 : Relay = Relay(name: "Relay6", status: false, onId: "FF0601", offId: "FF0600")
            relayArray.append(relay6)
            //defaults.set(relay6, forKey: keyRelay6)
            let relay7 : Relay = Relay(name: "Relay7", status: false, onId: "FF0701", offId: "FF0700")
            relayArray.append(relay7)
            //defaults.set(relay7, forKey: keyRelay7)
            let relay8 : Relay = Relay(name: "Relay8", status: false, onId: "FF0801", offId: "FF0800")
            relayArray.append(relay8)
            //defaults.set(relay8, forKey: keyRelay8)
            */
            do {
                let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: relayArray, requiringSecureCoding: false)
                defaults.set(encodedData, forKey: keyRelayArray)
                defaults.synchronize()
            } catch {
                print(error)
            }
       
            defaults.set(true, forKey: keyDataBaseInitialized)
        }
    }
    
    func getRelayArray() -> [Relay]
    {
        let defaults = UserDefaults.standard
        let decoded  = defaults.object(forKey: LocalDataBase.shared.keyRelayArray) as! Data
        do {
            
            guard let relayArray = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as? [Relay] else {
                fatalError("error")
            }
            return relayArray
        } catch {
            fatalError("error: \(error)")
        }
    }
    
    func getRelay(relayId: String) -> Relay
    {
        let relayArray = self.getRelayArray()
        let relay = relayArray.filter{ $0.onId == relayId || $0.offId == relayId }.first
        return relay!
    }
    
    func changeStatus(key: String, completion: @escaping (_ succsess : Bool) -> Void) {
        let relayArray = self.getRelayArray()
        let relay = relayArray.filter{ $0.onId == key || $0.offId == key }.first
        if let status = relay?.status
        {
            relay?.status = !status
        }
        do {
            let defaults = UserDefaults.standard
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: relayArray, requiringSecureCoding: false)
            defaults.set(encodedData, forKey: keyRelayArray)
            defaults.synchronize()
            completion(true)
        } catch {
            print(error)
        }
    }
    
    func setName(key: String, name: String, completion: @escaping (_ succsess : Bool) -> Void) {
        let relayArray = self.getRelayArray()
        let relay = relayArray.filter{ $0.onId == key || $0.offId == key }.first
        relay?.name = name
        
        do {
            let defaults = UserDefaults.standard
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: relayArray, requiringSecureCoding: false)
            defaults.set(encodedData, forKey: keyRelayArray)
            defaults.synchronize()
            completion(true)
        } catch {
            print(error)
        }
    }
    
    func resetDataBase() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: keyDataBaseInitialized)
        self.initRelayArray()
    }
}
