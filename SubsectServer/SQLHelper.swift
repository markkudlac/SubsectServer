//
//  SQLHelper.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-19.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import Foundation
import Squeal


class SQLHelper {
    
    private var db : Database!
    
    
    func start() -> Database? {
        db = openDatabase(dbname: CONST.dbsubServ)
        return db
    }
    
    
    func build() -> Bool {
  
        if start() != nil {
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
                "\(CONST.fieldStatus) CHAR(1) DEFAULT '\(CONST.ActiveStatus)'",
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
            } catch {
                print("Create Permission table failed")
                return false
            }
        } else {
            return false
        }
    /*
        initializeRegistry(app: "Testapp", sys: true, icon: "Hello icon", subsectId: 12345, title: "Title for test", permissions: "XYZ")
 */
  //      testDump(tableName : CONST.tableRegistry)
        
        return true
    }
        
        
    func initializeRegistry(app: String, sys: Bool, icon: String, subsectId: Int32, title: String, permissions: String){
        
        print("In initialize resity insert")
        
        var tmpvals : [String : Bindable]! = [
            CONST.fieldApp : app,
            CONST.fieldTitle : title,
            CONST.fieldIcon : icon,
            CONST.fieldPermissions : permissions,
            CONST.fieldSubsectId : subsectId,
            CONST.fieldHref : CONST.subHrefRempte,
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
        }
    }
    
    
    func testDump(tableName : String) {
    
        struct Contact {
            var testdic : [String : Bindable]!
            
            init(row:Statement) throws {
                
                testdic = row.dictionaryValue
                
            }
        }
        
        do {
            let contacts:[Contact] = try db.selectFrom(
                tableName,
                block: Contact.init
            )
            print("Dumping : \(contacts[0].testdic)")
            
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

/*
 if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS \(CONST.tableRegistry) ( \(CONST.fieldId) INTEGER PRIMARY KEY AUTOINCREMENT, \(CONST.fieldApp) TEXT, \(CONST.fieldTitle) TEXT, \(CONST.fieldType) CHAR(2) DEFAULT '\(CONST.dbUsr)', \(CONST.fieldIcon) TEXT, \(CONST.fieldPermissions) CHAR(3), \(CONST.fieldSubsectId) INTEGER, \(CONST.fieldHref) CHAR(50), \(CONST.fieldStatus) CHAR(1) DEFAULT '\(CONST.ActiveStatus)', \(CONST.fieldCreatedAt) INTEGER DEFAULT 0, \(CONST.fieldUpdatedAt) INTEGER DEFAULT 0 )",
 nil, nil, nil) != SQLITE_OK {
 let errmsg = String(cString: sqlite3_errmsg(db)!)
 print("error creating Registry table: \(errmsg)")
 }
 */
