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
    
    
    static func installZip(zipFile: String, packageName: String, dbType: String) -> String? {
        
        let zipTar = NVHTarGzip.init()
        var appsDirectory : String?
        
        let typeDirectory = Utilities.getDirectoryFromDb(dbType: dbType)
        
        do {
            let tmpDirectory = TemporaryFileUR(ext: packageName)
            
            let dataBase64 = Data(base64Encoded: zipFile, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
            if dataBase64 == nil {
                print("base64 invalid")
            }
            try dataBase64!.write(to: tmpDirectory.contentURL, options: [] );
            
            appsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(CONST.apps + typeDirectory).path
            
            if !FileManager.default.fileExists(atPath: appsDirectory!) {
                print("Creating directory")
                try FileManager.default.createDirectory(atPath: appsDirectory!, withIntermediateDirectories: true, attributes: nil)
            }
                print("Path : \(appsDirectory!)")
            
            try zipTar.unTarGzipFile(atPath: tmpDirectory.contentURL.path, toPath: appsDirectory!)
            appsDirectory = appsDirectory! + "/" + packageName
            
            /*
             let installDirectory = appsDirectory!
             let installDump = try FileManager.default.contentsOfDirectory(atPath: installDirectory)
             
             print("Directory documents contents : \(installDirectory)")
             for element in installDump {
             print(element)
             }
             */
        } catch {
            print("Error for directory write")
            appsDirectory = nil
        }
        
        return appsDirectory
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
        
        if let sourcePath = Bundle.main.path(forResource:CONST.installFile, ofType:"", inDirectory: "ServerAssets") {
            
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
    
    
    static func createTables(packageName :String, dbType: String){
        
        let schemas =  getSchemaFiles(packageName: packageName, dbType: dbType)
        
        for element in schemas {
            print("Schemas full path : \(element)")
            let sqlTable = getSchema(schemaPath: element, db: dbType + packageName)
            
        }
    }
    
    
    static func getSchema(schemaPath: String, db: String) -> Bool {
        
        var sqlTable :[String] = []
        var schema :String!
        var permissions = "FFF"
        var tableName :String!
        
        //let schema = FileManager.default.contents(atPath: schemaPath)
        do {
            schema = try String(contentsOfFile: schemaPath)
        } catch {
            print("Error reading schema contents")
        }
        
        sqlTable = schema.components(separatedBy: CharacterSet.newlines)
        
        if sqlTable.last!.hasSuffix("}") {
            sqlTable[sqlTable.count - 1] = sqlTable.last!.replacingOccurrences(of: "}", with: "")
        }
        
        for index in 0..<sqlTable.count {
            sqlTable[index] = sqlTable[index].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        for element in sqlTable {
            print("Looping : \(element)")
            
            if element.contains("#skip") {
                return true
            } else if element.contains("#permissions") {
                permissions = element.components(separatedBy: CharacterSet.whitespaces)[1]
                sqlTable.remove(at: sqlTable.index(of: element)!)
            } else if element.lowercased().contains("create")  && element.lowercased().contains("table"){
                tableName = element.components(separatedBy: CharacterSet.whitespaces)[2]
                sqlTable.remove(at: sqlTable.index(of: element)!)
            } else if element.hasPrefix(")") || element.count < 3 {
                sqlTable.remove(at: sqlTable.index(of: element)!)
            } else if element.hasSuffix(")") {
                sqlTable[sqlTable.index(of: element)!] = element.replacingOccurrences(of: ")", with: "")
            } else if element.hasSuffix(",") {
                sqlTable[sqlTable.index(of: element)!] = element.replacingOccurrences(of: ",", with: "")
            }
        }
        
        print("permisions : \(permissions)")
        print("Table name : \(tableName!)")
        sqlTable.insert("\(CONST.fieldId) INTEGER PRIMARY KEY AUTOINCREMENT", at: 0)
        sqlTable.append("\(CONST.fieldCreatedAt) INTEGER DEFAULT 0")
        sqlTable.append("\(CONST.fieldUpdatedAt) INTEGER DEFAULT 0")
        
        if  SQLHelper(dbName: db).createTable(tableName: tableName, tableBody: sqlTable, permissions: permissions) {
            return loadTypes(dbName: db, tableName: tableName, tableBody: sqlTable)
        } else {
            return false
        }
    }
    
    
    static func getSchemaFiles(packageName: String, dbType: String) -> [String] {
        
        var schemaFiles :[String] = []
        let typeDirectory = Utilities.getDirectoryFromDb(dbType: dbType)
        
        do {
            let installDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(CONST.apps + typeDirectory + "/" + packageName + CONST.schemasDirectory ).path
            
            schemaFiles = try FileManager.default.contentsOfDirectory(atPath: installDirectory)
            
       //     print("Directory documents contents : \(installDirectory)")
            for element in schemaFiles {
        //        print(element)
                if element.hasSuffix(CONST.loadfileExt) {
                    schemaFiles.remove(at: schemaFiles.index(of: element)!)
                } else {
                    schemaFiles[schemaFiles.index(of: element)!] = installDirectory + "/" + schemaFiles[schemaFiles.index(of: element)!]
                }
            }
        } catch {
            print("Error listing schemas")
        }
        return schemaFiles
    }
    
    
    static func loadTypes(dbName : String, tableName :String, tableBody :[String]) -> Bool {
        
        var typecode = 0
        var types :[String : Int] = [:]
        
        for element in tableBody {
        
            let field = element.components(separatedBy: CharacterSet.whitespaces)
            let fieldType = field[1].lowercased()
            
            if fieldType.contains("int")  {
                typecode = 1
            } else if fieldType.contains("double") || fieldType.contains("float") {
                typecode = 2
            } else if fieldType.contains("blob") {
                typecode = 3
            } else {
                typecode = 0
            }
            
            if typecode > 0 {
                types[field[0]] = typecode
            }
        }
        
        Utilities.setSchemaTypes(dbName: dbName, tableName:tableName, types: types)
        
        return true
    }
    
}


public final class TemporaryFileUR {
    
    public let contentURL: URL
    
    public init(ext: String) {
        contentURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)
    }
    
    deinit {
        DispatchQueue.global(qos: .utility).async { [contentURL = self.contentURL] in
            try? FileManager.default.removeItem(at: contentURL) }
    }
}

