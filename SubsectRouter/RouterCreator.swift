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
        
        router.get(CONST.apiPath + CONST.getMenu + ":funcid") { request, response, _ in

            let jray = SQLHelper(dbName: CONST.dbsubServ).getMenu(funcId: request.parameters["funcid"]!)
    //        print("jray : \(jray.rawString(options: [])!)" )
            do {
               try response.send(jray.rawString(options: [])!).end()
            } catch {
               Log.error("Caught an error while sending a response: \(error)")
            }
        }
        
        
        router.get(CONST.apiPath + CONST.apiTestPassword + ":passwd/:token/:funcid") { request, response, _ in
            
            var pwdTest = 0  //not equal
            
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
        
    
        router.get(CONST.apiPath + CONST.apiGetToken + ":funcid") { request, response, _ in
            
            do {
                var msg = Utilities.jsonDbReturn(rtnValue: true, recordId: 1, funcId: request.parameters[CONST.argsFuncId]!)
                
                msg[0][CONST.prefToken].string = Utilities.generateToken()
                
                try response.send(JSON(msg).rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
 
        // INSERT
        router.get(CONST.apiPath + CONST.apiInsertDb+"*") { request, response, _ in
            print("In insertdb 1")
            do {
                var msg = Utilities.jsonDbReturn(rtnValue: false, recordId: -1, funcId: request.queryParameters[CONST.argsFuncId]!)
                
                print("In insert router query string sqlpk : \(request.queryParameters[CONST.argsSQLpk]!)")
                 print("In insert router query string table : \(request.queryParameters[CONST.argsTable]!)")
              
                try response.send(JSON(msg).rawString(options: [])!).end()
            } catch {
                Log.error("Caught an error while sending a response: \(error)")
            }
        }
        
        //QUERRY
        router.get(CONST.apiPath + CONST.apiQueryDb+"*") { request, response, _ in
            print("In querydb 1")
            do {
                var msg = Utilities.jsonDbReturn(rtnValue: true, recordId: 0, funcId: "F000")
                
                print("In query string sqlpk : \(request.queryParameters[CONST.argsSQLpk]!)")
                
                
                let json = try? JSON(data: (request.queryParameters[CONST.argsSQLpk]?.data(using: .utf8)!)!)
                
                print("In insert router query string table : \(json![CONST.argsTable])")
                print("In insert router query string funcid : \(json![CONST.argsFuncId])")
                
                msg[0]["funcid"] = json![CONST.argsFuncId]
                
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
