//
//  String+IP.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 12/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation

extension String {
    func validateIpAddress() -> Bool {
        
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if self.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            // IPv6 peer.
            return true
        }
        else if self.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            // IPv4 peer.
            return true
        }
        
        return false;
    }
}
