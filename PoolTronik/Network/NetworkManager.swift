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
    let keyIP : String = "keyIP"
    let keyServerIP : String = "keyIP"
    
    public static let shared : NetworkManager = NetworkManager()
    
    func setStatus(key: String, completion: @escaping (_ succsess : Bool, _ relayId: String) -> Void) {
//        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
//            completion(true, key)
//        }
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
        return baseIp
    }
}
