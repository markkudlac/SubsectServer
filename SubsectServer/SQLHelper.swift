//
//  SQLHelper.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-19.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import Foundation
import SQLite3

class SQLHelper {
    
    private var db: OpaquePointer? = nil
    
    func start() -> OpaquePointer? {
        db = openDatabase(dbname: CONST.dbsubServ)
        return db
    }
    
    
    func build(){
        
        print("In build SQL")
        
        if start() != nil {
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS \(CONST.tableRegistry) ( \(CONST.fieldId) INTEGER PRIMARY KEY AUTOINCREMENT, \(CONST.fieldApp) TEXT, \(CONST.fieldTitle) TEXT, \(CONST.fieldType) CHAR(2) DEFAULT '\(CONST.dbUsr)', \(CONST.fieldIcon) TEXT, \(CONST.fieldPermissions) CHAR(3), \(CONST.fieldSubsectId) INTEGER, \(CONST.fieldHref) CHAR(50), \(CONST.fieldStatus) CHAR(1) DEFAULT '\(CONST.ActiveStatus)', \(CONST.fieldCreatedAt) INTEGER DEFAULT 0, \(CONST.fieldUpdatedAt) INTEGER DEFAULT 0 )",
                        nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating Registry table: \(errmsg)")
            }
            
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS \(CONST.tableSecure) ( \(CONST.fieldId) INTEGER PRIMARY KEY AUTOINCREMENT, \(CONST.fieldDbName) TEXT, \(CONST.fieldTableName) TEXT, \(CONST.fieldPermissions) CHAR(3), \(CONST.fieldCreatedAt) INTEGER DEFAULT 0, \(CONST.fieldUpdatedAt) INTEGER DEFAULT 0 )",
                nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating Permissions table: \(errmsg)")
            }
        }
        
        
        func initializeRegistry(app: String, sys: Bool, icon: String, subsectId: Int32, title: String, permissions: String){
            
        }
    
    }
    
    
    func openDatabase(dbname: String) -> OpaquePointer? {
        var opendb: OpaquePointer? = nil
        
        print("In openDB")
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbname)
        
        let err = sqlite3_open(fileURL.path, &opendb)
        if err == SQLITE_OK {
            print("Successfully opened connection to database")
            return opendb
        } else {
            print("Unable to open database.  err : \(err)")
            //        PlaygroundPage.current.finishExecution()
        }
        return nil
    }
}
