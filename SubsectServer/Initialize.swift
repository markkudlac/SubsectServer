//
//  Initialize.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-19.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import Foundation
import Kitura

class Initialize {
    
    class func start() -> Bool {
        
     //   if Utilities.isFirstLaunch(){
            installMenu()
            SQLHelper().build()
     //   }
        
        initializeKituraServer()
        
        return true
    }
    
    
    class func installMenu(){
        
        var destinationURL: URL!
   
        do {
            
            destinationURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
         //    print("Path : \(destinationURL.path)")
 
        } catch {
            print("Error: tar file not found")
        }
        
        if let sourcePath = Bundle.main.path(forResource:"rootpack", ofType:"targz", inDirectory: "ServerAssets") {
       //     let pubPath = sourcePath.replacingOccurrences(of: "/rootpack.targz", with: "")
      //      print("Tarfile path : \(pubPath)")
            
            let tarZip = NVHTarGzip.init()
            
            do {
                /*
                var xdir = try! FileManager.default.contentsOfDirectory(atPath: pubPath)
                xdir = try! FileManager.default.contentsOfDirectory(atPath: fileURL.path)
                print("Directory documents 1 contents : \(xdir[0])")
                */
        
                try tarZip.unTarGzipFile(atPath: sourcePath, toPath: destinationURL.path)
          
                /*
                xdir = try! FileManager.default.contentsOfDirectory(atPath: fileURL.path + "/sys/Menu")

               print("Directory public contents : ")
                for element in xdir {
                    print(element)
                }
 */
            } catch {
                print("unTar failed")
            }
            
        } else {
            print("File open error")
        }
        
    }
    
    
    private class func initializeKituraServer() {
        
        let queue = DispatchQueue(label: "server_thread")
        var router = Router()
        
        router = RouterCreator.create()
        Kitura.addHTTPServer(onPort: CONST.defaultPort, with: router)
    
        let networkData = IPUtility.getMyIP()
        if let ip = networkData.ip {
            let url = getUrl(ip: ip, port: "\(CONST.defaultPort)")
            
            print("Server url is \(url)")
        }
        
        queue.async {
            Kitura.start()
        }
    }
    
    
    
    private class func getUrl(ip: String, port: String) -> String {
        return ("http://" + ip + ":" + port)
    }
}
