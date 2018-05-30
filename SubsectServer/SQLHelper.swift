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
        print("in db init : \(dbName)")
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
    // print("Dic : \(element.dataDictionary["title"]!)")
                var tmpjray = JSON(element.dataDictionary)
                
                tmpjray[CONST.fieldHref].string = tmpjray[CONST.fieldHref].string!.replacingOccurrences(of: CONST.subHrefRemote, with: "\(CONST.httpProt)://" + "\(Utilities.getHostName()).\(CONST.defaultDomain)\(Utilities.alternatePort())/pkg/")
            
                jray.append(tmpjray)
            }
            
            jray[0]["db"].int = tableBucket.count
            jray[0]["rtn"] = true
       
    // if let jerr = xray["error"]["code"].string {
    //    print("JSON Error : \(jerr)")
    // }
            
        } catch {
            print("GetMenu failed")
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
            SQLHelper(dbName: CONST.dbsubServ).insertDB(tableName: CONST.tableSecure, data: json, funcId: "-1")
            
        } catch {
            print("Create table failed : \(tableName)")
            return false
        }
        return true
    }
    
    
    func insertDB(tableName :String, data :JSON, funcId :String) -> [JSON] {
        
        var insertColumns : [String] = []
        var insertData : [Bindable] = []
        var rtn = Utilities.jsonDbReturn(rtnValue: false, recordId: -1, funcId: funcId)
        
        print("In insertToDB")
        let sqlTypes = Utilities.getSchemaTypes(dbName: dbName, tableName: tableName)
        
        for (jkey, subJson) in data {
    //print("Loop insert key : \(jkey)")
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
            let recid = try db.insertInto(tableName, columns: insertColumns, values: insertData )
            print("Recid for insert table \(tableName) : \(recid)" )
            if recid != -1 {
                rtn = Utilities.jsonDbReturn(rtnValue: true, recordId: recid, funcId: funcId)
            }
        } catch {
            print("insertDB entry failed")
        }
        return rtn
    }
    
    
    func updateDB(tableName :String, data :JSON, query :String, args :JSON, funcId :String) -> [JSON] {
        
        var updateQuery : String = ""
        var setValues : String = ""
        var queryArgs : [Bindable] = []
        var rtn = Utilities.jsonDbReturn(rtnValue: false, recordId: -1, funcId: funcId)
        
        let andString = " AND "
        
        let sqlTypes = Utilities.getSchemaTypes(dbName: dbName, tableName: tableName)
        
        for (jkey, subJson) in data {
            setValues = setValues + "\(jkey) = "
            if sqlTypes![jkey] as? Int == 1 {
                setValues = setValues + (subJson.string!) + ", "
            } else if sqlTypes![jkey] as? Int == 2 {
                 setValues = setValues + (subJson.string!) + ", "
            } else if sqlTypes![jkey] as? Int == 3 {
                print("ERROR : Blob type not supported")
            } else {
                setValues = setValues + "'" + (subJson.string!) + "'" + ", "
            }
        }
        setValues = setValues + "\(CONST.fieldUpdatedAt) = \(Utilities.getTimeNow())"
        
        var buildQuery = false
        if query.count == 0 || query == "null" {
            buildQuery = true
        } else {
            updateQuery = query
        }
        
        for (jkey, subJson) in args {
    // print("Loop updateDB args key : \(jkey)")
            
            if buildQuery {
                updateQuery = updateQuery + "\(jkey) = ?\(andString)"
            }
            
            if sqlTypes![jkey] as? Int == 1 {
                queryArgs.append(subJson.int!)
            } else if sqlTypes![jkey] as? Int == 2 {
                queryArgs.append(subJson.float!)
            } else if sqlTypes![jkey] as? Int == 3 {
                print("ERROR : Blob type not supported")
            } else {
                queryArgs.append(subJson.string!)
            }
        }
        
        if (buildQuery){
            updateQuery = String(updateQuery.dropLast(andString.count))
        }
        
    // print("update values : " + setValues)
    // print("update query : " + updateQuery)
        
        do {
            let updateCount = try db.update(tableName, setExpr: setValues, whereExpr: updateQuery, parameters: queryArgs)
    // print("updateCount for update table \(tableName) : \(updateCount)" )
            if updateCount != -1 {
                rtn = Utilities.jsonDbReturn(rtnValue: true, recordId: Int64(updateCount), funcId: funcId)
            }
        } catch {
            print("updateDB entry failed")
        }
        return rtn
    }
    
    
    func removeDB(tableName :String, query :String, args :JSON, funcId :String) -> [JSON] {
        
        var updateQuery : String = ""
        var queryArgs : [Bindable] = []
        var rtn = Utilities.jsonDbReturn(rtnValue: false, recordId: -1, funcId: funcId)
        
        let andString = " AND "
        let sqlTypes = Utilities.getSchemaTypes(dbName: dbName, tableName: tableName)
        
        var buildQuery = false
        
        if query.count == 0 || query == "null" {
            buildQuery = true
        } else {
            updateQuery = query
        }
        
        for (jkey, subJson) in args {
    // print("Loop removeDB args key : \(jkey)")
            
            if buildQuery {
                updateQuery = updateQuery + "\(jkey) = ?\(andString)"
            }
            
            if sqlTypes![jkey] as? Int == 1 {
                queryArgs.append(subJson.int!)
            } else if sqlTypes![jkey] as? Int == 2 {
                queryArgs.append(subJson.float!)
            } else if sqlTypes![jkey] as? Int == 3 {
                print("ERROR : Blob type not supported")
            } else {
                queryArgs.append(subJson.string!)
            }
        }
        
        if (buildQuery){
            updateQuery = String(updateQuery.dropLast(andString.count))
        }
        
        do {
            let deleteCount = try db.deleteFrom(tableName, whereExpr: updateQuery, parameters: queryArgs)
            print("deleteCount for table \(tableName) : \(deleteCount)" )
            if deleteCount != -1 {
                rtn = Utilities.jsonDbReturn(rtnValue: true, recordId: Int64(deleteCount), funcId: funcId)
            }
        } catch {
            print("deleteDB failed")
        }
        return rtn
    }
    
    
    func queryDB(query :String, args :JSON, limits :JSON, funcId :String) -> [JSON] {
        
        var rtn = Utilities.jsonDbReturn(rtnValue: false, recordId: -1, funcId: funcId)
        
        struct DataBucket {
            var dataDictionary : [String : Bindable]!
            
            init(row:Statement) throws {
                dataDictionary = row.dictionaryValue
            }
        }
        
        do {
            var statement : [String]!
            if (query.contains("WHERE")) {
                statement = query.components(separatedBy: " WHERE ")
            } else {
                statement = query.components(separatedBy: " where ")
            }
            
            var whereClause : String?
      
            if statement.count == 2 {
                whereClause = statement[1]
            }
            
            let tableBucket:[DataBucket] = try db.selectFrom(
                statement[0],
                whereExpr: whereClause,
                limit: limits["limit"].int,
                offset: limits["offset"].int,
                block: DataBucket.init
            )
            
            for element in tableBucket {
      //          print("Dic first name : \(element.dataDictionary["firstname"]!)")
                rtn.append(JSON(element.dataDictionary))
            }
            
            rtn[0][CONST.argsDb].int = tableBucket.count
            rtn[0]["rtn"] = true
            
        } catch {
            print("queryDB failed")
        }
        return rtn
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
 
    /*
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
     */
    
}


