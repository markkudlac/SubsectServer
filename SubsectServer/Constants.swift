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
    static let defaultDomain = "subsect.net"
    static let defaultServer = "www." + defaultDomain
    static let selectServer = "selectServer"
    static let alternateServer = "alternateServer"
    static let prefToken = "token"
    static let launchedBefore = "hasBeenLaunchedBeforeFlag"
    static let apps = "Apps/"
    static let sysDir = "sys"
    static let usrDir = "usr"
    static let loadfileExt = ".ld"
    static let types = "types_"
    
    static let httpProt = "http"
    static let installFile = "rootpack.targz"
    static let apiPath = "/api/"
    static let getMenu = "getMenu/"
    static let apiQueryDb = "queryDB"
    static let apiInsertDb = "insertDB"
    static let apiUpdateDb = "updateDB"
    static let apiRemoveDb = "removeDB"
    static let apiTestPassword = "testPassword/"
    static let apiGetToken = "getToken/"
    static let apiGetIpAdd = "getIPadd"
    static let argsSQLpk = "sqlpk"
    static let argsTable = "table"
    static let argsFuncId = "funcid"
    
    static let subServ = "subserv";
    static let dbSys = "S_";
    static let dbUsr = "U_";
    static let subHrefRemote = "Sub_Href_Remote"
    static let dbDirectory = "databases/"
    static let schemasDirectory = "/schemas"
    static let dbsubServ = dbSys + subServ

    static let fieldId = "id";
    static let fieldStatus = "status";
    static let activeStatus = "A";
    static let deleteStatus = "D";
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
