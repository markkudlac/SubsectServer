//
//  SQLHelper.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-19.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import Foundation
import Squeal
import SwiftyJSON

class SQLHelper {
    
    private var db : Database!
    private var dbName : String!

    init(dbName: String) {
        print("in db init")
        db = openDatabase(dbname: CONST.dbDirectory + dbName)
        self.dbName = dbName
    }
    
    
    func build() -> Bool {
  
        if db != nil && self.dbName == CONST.dbsubServ {
            do {
                try db.createTable(CONST.tableRegistry, definitions: [
                "\(CONST.fieldId) INTEGER PRIMARY KEY AUTOINCREMENT",
                "\(CONST.fieldApp) TEXT",
                "\(CONST.fieldTitle) TEXT",
                "\(CONST.fieldType) CHAR(2) DEFAULT '\(CONST.dbUsr)'",
                "\(CONST.fieldIcon) TEXT",
                "\(CONST.fieldPermissions) CHAR(3)",
                "\(CONST.fieldSubsectId) INTEGER",
                "\(CONST.fieldHref) CHAR(50)",
                "\(CONST.fieldStatus) CHAR(1) DEFAULT '\(CONST.activeStatus)'",
                "\(CONST.fieldCreatedAt) INTEGER DEFAULT 0",
                "\(CONST.fieldUpdatedAt) INTEGER DEFAULT 0"
                ], ifNotExists: true)
            } catch {
                print("Create Registry table failed")
                return false
            }
        
            do {
                try db.createTable(CONST.tableSecure, definitions: [
                "\(CONST.fieldId) INTEGER PRIMARY KEY AUTOINCREMENT",
                "\(CONST.fieldDbName) TEXT",
                "\(CONST.fieldTableName) TEXT",
                "\(CONST.fieldPermissions) CHAR(3)",
                "\(CONST.fieldCreatedAt) INTEGER DEFAULT 0",
                "\(CONST.fieldUpdatedAt) INTEGER DEFAULT 0"
                ], ifNotExists: true)
                
                Utilities.setSchemaTypes(dbName: self.dbName, tableName: CONST.tableSecure, types: [CONST.fieldId : 1])
            } catch {
                print("Create Permission table failed")
                return false
            }
        } else {
            return false
        }
        return true
    }
        
        
    func initializeRegistry(app: String, sys: Bool, icon: String, subsectId: Int, title: String, permissions: String) -> Bool {
        
    //    print("In initialize resity insert")
        
        var tmpvals : [String : Bindable]! = [
            CONST.fieldApp : app,
            CONST.fieldTitle : title,
            CONST.fieldIcon : icon,
            CONST.fieldPermissions : permissions,
            CONST.fieldSubsectId : subsectId,
            CONST.fieldHref : CONST.subHrefRemote + app,
            CONST.fieldCreatedAt : Utilities.getTimeNow()
        ]
        
        if sys {
            tmpvals[CONST.fieldType] = CONST.dbSys
        } else {
            tmpvals[CONST.fieldType] = CONST.dbUsr
        }
        
        do {
            try db.insertInto(CONST.tableRegistry,
                values: tmpvals )
        } catch {
            print("Resitry entry failed")
            return false
        }
        return true
    }
    
    
    func getMenu(funcId: String) -> JSON {
        
        var jray = Utilities.jsonDbReturn(rtnValue: false, recordId: 0, funcId: funcId)
        
        struct DataBucket {
            var dataDictionary : [String : Bindable]!
            
            init(row:Statement) throws {
                dataDictionary = row.dictionaryValue
            }
        }
        
        do {
            let tableBucket:[DataBucket] = try db.selectFrom(
                CONST.tableRegistry,
                whereExpr: "\(CONST.fieldStatus) = '\(CONST.activeStatus)'",
                block: DataBucket.init
            )
            
            for element in tableBucket {
       //     print("Dic : \(element.dataDictionary["title"]!)")
                var tmpjray = JSON(element.dataDictionary)
                
                tmpjray[CONST.fieldHref].string = tmpjray[CONST.fieldHref].string!.replacingOccurrences(of: CONST.subHrefRemote, with: "\(CONST.httpProt)://" + "\(Utilities.getHostName()).\(CONST.defaultDomain)\(Utilities.alternatePort())/pkg/")
            
                jray.append(tmpjray)
            }
            
            jray[0]["db"].int = tableBucket.count
            jray[0]["rtn"] = true
       
       //     if let jerr = xray["error"]["code"].string {
        //        print("JSON Error : \(jerr)")
       //     }
            
      //      for element in xray {
       //     print("JSON : \(xray[0]["title"].string!)")
       //     }
  //          print("Dumping \(CONST.tableRegistery) : \(tableBucket[0].dataDictionary)")
            
        } catch {
            print("Testdaump failed")
        }
        return JSON(jray)
    }
    
    
    func createTable(tableName :String, tableBody :[String], permissions :String) -> Bool {
        
        do {
            try db.createTable(tableName, definitions: tableBody, ifNotExists: true)
            
            let json = JSON([
                CONST.fieldDbName : dbName,
                CONST.fieldTableName : tableName,
                CONST.fieldPermissions : permissions
                ])
            SQLHelper(dbName: CONST.dbsubServ).insertToDB(tableName: CONST.tableSecure, data: json, funcId: "-1")
            
        } catch {
            print("Create table failed : \(tableName)")
            return false
        }
        return true
    }
    
    
    func insertToDB(tableName :String, data :JSON, funcId :String) -> Bool {
        
        var insertColumns : [String] = []
        var insertData : [Bindable] = []
        
        print("In insertToDB")
        let sqlTypes = Utilities.getSchemaTypes(dbName: dbName, tableName: tableName)
        
        for (jkey, subJson) in data {
    //        print("Loop insert key : \(jkey)")
            insertColumns.append(jkey)
            if sqlTypes![jkey] as? Int == 1 {
                insertData.append(subJson.int!)
            } else if sqlTypes![jkey] as? Int == 2 {
                insertData.append(subJson.float!)
            } else if sqlTypes![jkey] as? Int == 3 {
                print("ERROR : Blob type not supported")
            } else {
                insertData.append(subJson.string!)
            }
        }
        
        insertColumns.append(CONST.fieldCreatedAt)
        insertData.append(Utilities.getTimeNow())
        
        do {
            try db.insertInto(tableName, columns: insertColumns, values: insertData )
        } catch {
            print("Resitry entry failed")
            return false
        }
        return true
    }
    
    
    func testDump(tableName : String) {
    
        struct DataBucket {
            var dataDictionary : [String : Bindable]!
            
            init(row:Statement) throws {
                dataDictionary = row.dictionaryValue
            }
        }
        
        do {
            let tableBucket:[DataBucket] = try db.selectFrom(
                tableName,
                block: DataBucket.init
            )
            print("Dumping : \(tableBucket[0].dataDictionary)")
            
        } catch {
            print("Testdaump failed")
        }
    }
    
    func openDatabase(dbname: String) -> Database? {
        var opendb: Database? = nil

        print("In openDB")
        do {
            let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(dbname)
            opendb = try Database(path: fileURL.path)
        } catch {
            print("DB open failed")
        }
        return opendb
    }
 
}


