//
//  Utility.swift
//  SubServiOS
//
//  Created by Mark Kudlac on 2018-05-09.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


class Utilities {
    
    static func setTextFromDefault(field: UITextField, valueTag: String) {
        
        if let fieldValue:String = UserDefaults.standard.string(forKey: valueTag) {
            field.text = fieldValue
        } else {
            field.text = ""
        }
    }

    
    static func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: CONST.launchedBefore) {
            UserDefaults.standard.set(true, forKey: CONST.launchedBefore)
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
    
    static func getTimeNow() -> Int64 {
        // current UNIX time in milliseconds
        return Int64(Date().timeIntervalSince1970) * 1000
    }
    
    
    static func getNameServer() -> String {
        
        var nameServer = CONST.defaultServer
        let defaults = UserDefaults.standard
        
        if nil != defaults.string(forKey: CONST.alternateServer) &&
            !UserDefaults.standard.bool(forKey: CONST.selectServer) {
            nameServer = defaults.string(forKey: CONST.alternateServer)!
        }
        
        return nameServer
    }
    
    static func getHostName() -> String {
        
        var hostName = "mark"
        if let hostNameTmp = UserDefaults.standard.string(forKey: CONST.hostName) {
            hostName = hostNameTmp
        }
        
        return hostName
    }
    
    
    static func jsonDbReturn(rtnValue: Bool, recordId: Int, funcId: String) -> [JSON] {
        return [
        JSON(["rtn": rtnValue, "db": recordId, "funcid": funcId])
        ]
    }
    
    
    static func useDefaultServer() -> Bool {
        return UserDefaults.standard.bool(forKey: CONST.selectServer)  ||
            nil == UserDefaults.standard.string(forKey: CONST.alternateServer)
    }
    
    
    static func alternatePort() -> String {
        var port = ""
        
        if !useDefaultServer() {
            let altPort = UserDefaults.standard.string(forKey: CONST.alternateServer)!.components(separatedBy: ":")
            
            if altPort.count > 1 {
                port = ":"+altPort[1]
            }
            
        }
        return port
    }
    
    
    static func setSchemaTypes(dbName :String, tableName :String, types: [String : Int]) {
        
        let keyName = CONST.types+dbName+tableName
        
        print("setScemaTpes : \(keyName)  types : \(types)")
        UserDefaults.standard.set(types, forKey: keyName)
    }
    
    
    static func getSchemaTypes(dbName :String, tableName :String) -> [String : Any]! {
        
        let keyName = CONST.types+dbName+tableName
        
        
        let types = UserDefaults.standard.dictionary(forKey: keyName)
        
        print("getScemaTpes : \(keyName)  types : \(types)")
        
        return types
    }
    
    
    static func getPassword() -> String? {
        var hostName = "mark"
        var hostPassword = "6149garner"
        
        if let hostNameTmp:String = UserDefaults.standard.string(forKey: CONST.hostName) {
            hostName = hostNameTmp
        }
            
        if let hostPasswordTmp = UserDefaults.standard.string(forKey: CONST.hostPassword) {
            hostPassword = hostPasswordTmp
        }
        
        var hash = SHA1.hexString(from: hostName + hostPassword)!.replacingOccurrences(of: " ", with: "").lowercased()
        //      print("SHA-1 : " + hash) // Another String Value
           
        return hash
    }
    
    
    static func setPassword(password: String) -> Bool {
        
        return true
    }
    
    
    static func getToken() -> String {
        var token = "6"
        
        if let tokenTmp:String = UserDefaults.standard.string(forKey: CONST.prefToken) {
            token = tokenTmp
        }
        
        return token
    }
    
    
    static func setToken(token: String){
        
        UserDefaults.standard.set(token, forKey: CONST.prefToken)
    }
    
    
    static func generateToken() -> String {
        var toke = getToken()
        
        toke = toke + getPassword()! + String(getTimeNow())
        toke =  SHA1.hexString(from: toke)!.replacingOccurrences(of: " ", with: "").lowercased()
        return toke
    }
    
    
    static func getDirectoryFromDb(dbType: String) -> String {
    
        if dbType.hasPrefix(CONST.dbSys) {
            return CONST.sysDir
        } else {
            return CONST.usrDir
        }
    }
}


class IPUtility {
    static let Wifi = "wifi"
    static let Cellular = "3g"
    
    class func getMyIP() -> (ip: String?, network: String?) {
        // Get list of all interfaces on the local machine:
        var interfaceAddress : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaceAddress) == 0 else { return (nil, nil) }
        defer {
            freeifaddrs(interfaceAddress)
        }
        guard let firstAddress = interfaceAddress else { return (nil, nil) }
        var secondaryAddress: String? = nil //will be returned if there's no wifi connection
        // For each interface ...
        for ifptr in sequence(first: firstAddress, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily != UInt8(AF_INET) && addrFamily != UInt8(AF_INET6) {
                continue
            }
            
            // Check interface name:
            let name = String(cString: interface.ifa_name)
            if name != "en0" && name.range(of: "pdp") == nil  {
                continue
            }
            
            // Convert interface address to a human readable string:
            var address = interface.ifa_addr.pointee
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(&address, socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname, socklen_t(hostname.count),
                        nil, socklen_t(0), NI_NUMERICHOST)
            let returnAddress = String(cString: hostname)
            if returnAddress.isEmpty {
                continue
            }
            if(returnAddress.range(of: "::") != nil) {
                continue
            }
            if(name == "en0") {
                return (returnAddress, IPUtility.Wifi)
            } else {
                secondaryAddress = returnAddress
            }
        }
        return (secondaryAddress, IPUtility.Cellular)
    }
}
