//
//  Constants.swift
//  SubServiOS
//
//  Created by Mark Kudlac on 2018-05-09.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import Foundation

enum CONST {
    static let internalPort = 8080
    
    static let hostName = "hostName"
    static let hostPassword = "hostPassword"
    static let hostEmail = "hostEmail"
    static let defaultServer = "www.subsect.net"
    static let selectServer = "selectServer"
    static let alternateServer = "alternateServer"
    static let defaultPort = 8080
    static let launchedBefore = "hasBeenLaunchedBeforeFlag"
    static let apps = "Apps/"
    static let sysDir = "sys"
    static let usrDir = "usr"
    
    static let httpProt = "http"
    static let apiPath = "/api/"
    static let getMenu = "getMenu/"
    static let subServ = "subserv";
    static let dbSys = "S_";
    static let dbUsr = "U_";
    static let subHrefRempte = "Sub_Href_Remote"
    static let sqlExt = ".sqlite3"
    static let dbsubServ = dbSys + subServ + sqlExt

    static let fieldId = "id";
    static let fieldStatus = "status";
    static let ActiveStatus = "A";
    static let DeleteStatus = "D";
    static let fieldCreatedAt = "created_at";
    static let fieldUpdatedAt = "updated_at";
    
    static let tableRegistry = "registry";
    static let fieldApp = "app";
    static let fieldTitle = "title";
    static let fieldType = "type";
    static let fieldSubsectId = "subsectid";
    static let fieldIcon = "icon";
    static let fieldPermissions = "permissions";
    static let fieldHref = "href";
    
    static let tableSecure = "secure";
    static let fieldDbName = "dbname";
    static let fieldTableName = "tablename";
}
