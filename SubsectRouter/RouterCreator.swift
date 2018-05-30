//
/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Kitura
import LoggerAPI
import CoreSpotlight
import SwiftyJSON


public struct RouterCreator {
     public static func create() -> Router {
        let router = Router()
   
        let cors = CORS(options: Options())
        
        /*
         let options = Options(allowedOrigin: .origin("www.abc.com"), methods: ["GET","PUT"], allowedHeaders: ["Content-Type"], maxAge: 5)
         let cors = CORS(options: options))
         */
        
        router.all("/", middleware: cors)
     //   router.all("/api/savefile", middleware: BodyParser())
        
        router.get(CONST.apiPath + CONST.getMenu + ":funcid") { request, response, _ in

            let rtn = SQLHelper(dbName: CONST.dbsubServ).getMenu(funcId: request.parameters["funcid"]!)
    //        print("jray : \(jray.rawString(options: [])!)" )
            do {
               try response.send(rtn.rawString(options: [])!).end()
            } catch {
               Log.error("Caught an error while sending a response: \(error)")
            }
        }
        

// SAVE FILE
        router.post(CONST.apiPath + CONST.apiSaveFile) { request, response, _ in
            
            do {
                var rtn = JSON(["rtn" : false])
               
                if let strBody = try request.readString() {
            //print("In save file : \(strBody)")
                    
                    let args = strBody.split(separator: "&")
                    let fileName = args[0].split(separator: "=")[1] //arg : "filename"
                    let fileContent = args[1].dropFirst(CONST.fileContent.count + 1) // = sign
                    
                    let pathSplit = fileName.split(separator: "/")
                    let rootPath = fileName.dropLast((pathSplit.last?.count)!+1)
                    
                    do {
                        let destinationDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(CONST.apps+rootPath.dropFirst(1))
                        
            //print("Path for file save directory : \(destinationDirectory.path)")
                        
                        if !FileManager.default.fileExists(atPath: destinationDirectory.path) {
                                  print("Creating directory")
                            try FileManager.default.createDirectory(atPath: destinationDirectory.path, withIntermediateDirectories: true, attributes: nil)
                        }
                        
            //print("Final save path : \(destinationDirectory.appendingPathComponent(String(pathSplit.last!)).path)")
                        
                        try fileContent.removingPercentEncoding!.write(to: destinationDirectory.appendingPathComponent(String(pathSplit.last!)), atomically: true, encoding: String.Encoding.utf8)
                        
                        rtn = JSON(["rtn" : true])
                    } catch {
                        print("Error: tar file not found")
                    }
                } else {
                    print("Filesave router could not read body")
                }
                try response.send(rtn.rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
        
 
// DELETE FILE
        router.post(CONST.apiPath + CONST.apiDeleteFile) { request, response, _ in
            
            do {
                var rtn = JSON(["rtn" : false])
                
                    if let strBody = try request.readString() {
                           print("In delete file : \(strBody)")
                    
                    let args = strBody.split(separator: "&")
                    let fileName = args[0].split(separator: "=")[1]     //arg : "filename"
                    
                    do {
                        let deletePath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(CONST.apps+fileName.dropFirst(1))
                        
        //print("Path for file delete : \(deletePath.path)")
                       try FileManager.default.removeItem(at: deletePath)
                        
                        rtn = JSON(["rtn" : true])
                    } catch {
                        print("Error: tar file not found")
                    }
                }
                try response.send(rtn.rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
        
   
// TEST PASSWORD
        router.get(CONST.apiPath + CONST.apiTestPassword + ":passwd/:token/:funcid") { request, response, _ in
            
            var pwdTest : Int64 = 0  //not equal
            
            if (request.parameters["token"]! == "T" &&
                request.parameters["passwd"]! == Utilities.getToken()) ||
                request.parameters["passwd"]! == Utilities.getPassword() {
                pwdTest = 1
            }
            
            do {
                let msg = Utilities.jsonDbReturn(rtnValue: true, recordId: pwdTest, funcId: request.parameters[CONST.argsFuncId]!)
                
                try response.send(JSON(msg).rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
        

// GET TOKEN
        router.get(CONST.apiPath + CONST.apiGetToken + ":" + CONST.argsFuncId) { request, response, _ in
            
            do {
                var msg = Utilities.jsonDbReturn(rtnValue: true, recordId: 1, funcId: request.parameters[CONST.argsFuncId]!)
                
                msg[0][CONST.prefToken].string = Utilities.generateToken()
                
                try response.send(JSON(msg).rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
 
        
// INSERT
        router.post(CONST.apiPath + CONST.apiInsertDb) { request, response, _ in
    
            do {
                var msg = Utilities.jsonDbReturn(rtnValue: false, recordId: -1, funcId: "-1")
                
               if var sqlpk = try request.readString()
               {
                    sqlpk = String(sqlpk.split(separator: "=")[1])  //This must be first
                    sqlpk = sqlpk.removingPercentEncoding!
        //     print("In insertDB : \(sqlpk)")
               
                
                    let json = try JSON(data: (sqlpk.data(using: .utf8)!))
        //print("Insert router post string table : \(json[CONST.argsTable])")
                    msg = SQLHelper(dbName: json[CONST.argsDb].string!).insertDB(tableName: json[CONST.argsTable].string!, data: json[CONST.argsValues], funcId: json[CONST.argsFuncId].string!)
                } else {
                    print("insertDB routing error reading body")
                }
                
                try response.send(JSON(msg).rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
   

// UPDATE
        router.post(CONST.apiPath + CONST.apiUpdateDb) { request, response, _ in
            
            do {
                var msg = Utilities.jsonDbReturn(rtnValue: false, recordId: -1, funcId: "-1")
                
                if var sqlpk = try request.readString()
                {
                    sqlpk = String(sqlpk.split(separator: "=")[1]) //This must be first
                    sqlpk = sqlpk.removingPercentEncoding!
        print("In updateDB : \(sqlpk)")
                    
                    let json = try JSON(data: (sqlpk.data(using: .utf8)!))
        print("Update router post string table : \(json[CONST.argsTable])")
                    
                    msg = SQLHelper(dbName: json[CONST.argsDb].string!).updateDB(tableName: json[CONST.argsTable].string!, data: json[CONST.argsValues], query: json[CONST.argsQuery].string!, args: json[CONST.argsArgs], funcId: json[CONST.argsFuncId].string!)
                } else {
                    print("updateDB routing error reading body")
                }
                
                try response.send(JSON(msg).rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
 
        
// DELETE
        router.get(CONST.apiPath + CONST.apiRemoveDb) { request, response, _ in
            
            do {
                var msg = Utilities.jsonDbReturn(rtnValue: false, recordId: -1, funcId: "-1")
                
                    print("In removedb string sqlpk : \(request.queryParameters[CONST.argsSQLpk]!)")
                
                let json = try JSON(data: (request.queryParameters[CONST.argsSQLpk]?.data(using: .utf8)!)!)
                
                print("In removeDB router query string table : \(json[CONST.argsTable])")
                
                msg = SQLHelper(dbName: json[CONST.argsDb].string!).removeDB(tableName: json[CONST.argsTable].string!, query: json[CONST.argsQuery].string!, args: json[CONST.argsArgs], funcId: json[CONST.argsFuncId].string!)
                
                try response.send(JSON(msg).rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
      
        
// QUERRY
        router.get(CONST.apiPath + CONST.apiQueryDb) { request, response, _ in
          
            do {
                 var msg = Utilities.jsonDbReturn(rtnValue: true, recordId: 0, funcId: "-1")
                
            //    print("In query string sqlpk : \(request.queryParameters[CONST.argsSQLpk]!)")
                
                let json = try JSON(data: (request.queryParameters[CONST.argsSQLpk]?.data(using: .utf8)!)!)
                
                print("In query router query string table : \(json[CONST.argsTable])")
   
                msg = SQLHelper(dbName: json[CONST.argsDb].string!).queryDB(query: json[CONST.argsQuery].string!, args: json[CONST.argsArgs], limits: json[CONST.argsLimits], funcId: json[CONST.argsFuncId].string!)
                
         //       msg[0][CONST.argsFuncId] = json[CONST.argsFuncId]
                
                try response.send(JSON(msg).rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
        
// GET IP ADDRESS
        router.get(CONST.apiPath + CONST.apiGetIpAdd + ":" + CONST.argsFuncId) { request, response, _ in
            
            do {
                print("In getIPaddress : \(Utilities.getHostAddress())")
                var msg = Utilities.jsonDbReturn(rtnValue: true, recordId: 1, funcId: request.parameters[CONST.argsFuncId]!)
                
                msg[0][CONST.argsIpAddress].string = Utilities.getHostAddress()
                
                try response.send(JSON(msg).rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
        
        
        do {
            let serverRoot = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask,appropriateFor: nil, create: false).appendingPathComponent(CONST.apps).path
            
        //    print("Path In Router : \(serverRoot)")
            router.all("/", middleware: StaticFileServer(path: serverRoot))
        } catch {
            print("Failed to get server root")
        }
        
        return router
     }
}
