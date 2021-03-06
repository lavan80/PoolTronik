//
//  NetworkManager.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 11/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation

class NetworkManager {
    
    private var dataTask: URLSessionDataTask?
    private var baseIp: String = "192.168.1.199"
    private var baseServerIp: String = ""
    let keyIP : String = "keyIP"
    let keyServerIP : String = "keyServerIp"
    
    public static let shared : NetworkManager = NetworkManager()
    
    func setStatus(key: String, completion: @escaping (_ succsess : Bool, _ relayId: String) -> Void) {
        dataTask?.cancel()
        if let urlComponents = URLComponents(string: "http://\(self.getIp())/\(key)") {
           
            guard let url = urlComponents.url else { return }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let _ = data, let _ = response as? HTTPURLResponse, error == nil else {
                    completion(false, key)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse
                {
                    if httpResponse.statusCode == 200
                    {
                        completion(true, key)
                    }
                }
                }.resume()
        }
    }
    
    func updateToken(token: String, completion: @escaping (_ succsess : Bool) -> Void) {
        dataTask?.cancel()
        if let urlComponents = URLComponents(string: "http://\(self.getServerIp()):8080/refresh") {
           
            guard let url = urlComponents.url else { return }
            let json: [String: Any] = ["uniqId": "",
                                       "token": token,
                                       "platform": "iOS"]

            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // create post request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let _ = data, let _ = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse
                {
                    if httpResponse.statusCode == 200
                    {
                        completion(true)
                    }
                }
                }.resume()
        }
    }
    
    func schedule(pTScheduleDate: PTScheduleDate, completion: @escaping (_ succsess : Bool) -> Void) {
        dataTask?.cancel()
        if let urlComponents = URLComponents(string: "http://\(self.getServerIp()):8080/schedule") {
           
            guard let url = urlComponents.url else { return }

            do {
                let dict = try pTScheduleDate.asDictionary()
                 var request = URLRequest(url: url)
                           request.httpMethod = "POST"
                            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                           request.httpBody = jsonData
                           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                           request.addValue("application/json", forHTTPHeaderField: "Accept")
                           URLSession.shared.dataTask(with: request) { (data, response, error) in
                               guard let _ = data, let _ = response as? HTTPURLResponse, error == nil else {
                                   completion(false)
                                   return
                               }
                               if let httpResponse = response as? HTTPURLResponse
                               {
                                   if httpResponse.statusCode == 200
                                   {
                                       completion(true)
                                   }
                               }
                               }.resume()
            } catch {
                print(error)
            }
        }
    }
    
    func getScheduale(relay: Int, completion: @escaping (_ succsess : Bool, _ tasks: [PTScheduleDate]) -> Void) {
        dataTask?.cancel()
        if let urlComponents = URLComponents(string: "http://\(self.getServerIp()):8080/tasks?relay=\(relay)") {
           
            guard let url = urlComponents.url else { return }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let _ = data, let _ = response as? HTTPURLResponse, error == nil else {
                    completion(false, [])
                    return
                }
                if let httpResponse = response as? HTTPURLResponse
                {
                    if httpResponse.statusCode == 200
                    {
                        do {
                            
                            let decoder = JSONDecoder()
                            let scheduale = try decoder.decode([PTScheduleDate].self, from: data!)
                            completion(true, scheduale)
                        } catch {
                            print("error:\(error)")
                            completion(false, [])
                        }
                        
                    }
                }
                }.resume()
        }
    }
    
    func deleteSchedule(relayId: Int, completion: @escaping (_ succsess : Bool) -> Void) {
        dataTask?.cancel()
        if let urlComponents = URLComponents(string: "http://\(self.getServerIp()):8080/tasks/delete?id=\(relayId)") {
           
            guard let url = urlComponents.url else { return }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let _ = data, let _ = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse
                {
                    if httpResponse.statusCode == 200
                    {
                        completion(true)
                    }
                }
                }.resume()
        }
    }
    
    private func dataToDictionary(data: Data?) -> NSDictionary? {
        do {
            guard let data = data else {
                print("No data")
                return nil
            }
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                print("Could not parse json")
                return nil
            }
            return json
        }
        catch let error as NSError {
            print(error.debugDescription)
            return nil
        }
    }

    private func isValidStatus(dictionary: NSDictionary?) -> Bool
    {
        if let dic = dictionary {
            return dic["status"] as? String == "OK"
        }
        return false
    }
    
    func setIP(ip: String) {
        let defaults = UserDefaults.standard
        defaults.set(ip, forKey: keyIP)
        defaults.synchronize()
    }
    
    func getIp() -> String
    {
        let defaults = UserDefaults.standard
        if let ip = defaults.value(forKey: keyIP)
        {
            return ip as! String
        }
        return baseIp
    }
    
    func setServerIP(ip: String) {
        let defaults = UserDefaults.standard
        defaults.set(ip, forKey: keyServerIP)
        defaults.synchronize()
    }
    
    func getServerIp() -> String
    {
        let defaults = UserDefaults.standard
        if let ip = defaults.value(forKey: keyServerIP)
        {
            return ip as! String
        }
        return baseServerIp
    }
}

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}
