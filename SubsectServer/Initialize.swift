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
    
    static func start() -> Bool {
        
     //   if Utilities.isFirstLaunch(){
            installMenu()
        
        do {
            let destinationDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(CONST.dbDirectory).path
            //     print("Path for DB install : \(destinationDirectory)")
            
            if !FileManager.default.fileExists(atPath: destinationDirectory) {
                 //     print("Creating db directory")
                try FileManager.default.createDirectory(atPath: destinationDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Error: DB directory creation failed")
        }
        
        SQLHelper(dbName: CONST.dbsubServ).build()
     //   }
        
        initializeKituraServer()
        
        return true
    }
    
    
    static func installMenu(){
        
        var destinationDirectory: String!
   
        do {
            destinationDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(CONST.apps).path
        //     print("Path for Menu install : \(destinationDirectory!)")
 
            if !FileManager.default.fileExists(atPath: destinationDirectory) {
          //      print("Creating directory")
                try FileManager.default.createDirectory(atPath: destinationDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Error: tar file not found")
        }
        
        if let sourcePath = Bundle.main.path(forResource:"rootpack", ofType:"targz", inDirectory: "ServerAssets") {
            
            let tarZip = NVHTarGzip.init()
            
            do {
                try tarZip.unTarGzipFile(atPath: sourcePath, toPath: destinationDirectory)
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
        Kitura.addHTTPServer(onPort: CONST.internalPort, with: router)
    
        let networkData = IPUtility.getMyIP()
        if let ip = networkData.ip {
            let url = getUrl(ip: ip, port: "\(CONST.internalPort)")
            print("Server url is \(url)")
        }
        
        queue.async {
            Kitura.start()
        }
    }
    
    
    private static func getUrl(ip: String, port: String) -> String {
        return ("http://" + ip + ":" + port)
    }
    
    
    static func createTables(packageName :String){
        
       let xschems =  getSchemaFiles(packageName: packageName)
        
    }
    
    
    static func getSchema(packageName: String) -> [String] {
        
        var sqlTable :[String] = []
        
        sqlTable[1] = ""
        sqlTable[2] = "FFF"
        
        return sqlTable
    }
    
    
    static func getSchemaFiles(packageName: String) -> [String] {
        
        var schemaFiles :[String] = []
        
        do {
            let installDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(CONST.apps + CONST.sysDir + "/" + packageName + CONST.schemasDirectory ).path
            
            schemaFiles = try FileManager.default.contentsOfDirectory(atPath: installDirectory)
            
            print("Directory documents contents : \(installDirectory)")
            for element in schemaFiles {
        //        print(element)
                if element.hasSuffix(CONST.loadfileExt) {
                    schemaFiles.remove(at: schemaFiles.index(of: element)!)
                }
            }
        } catch {
            print("Error listing schemas")
        }
        
        return schemaFiles
    }
    
}
