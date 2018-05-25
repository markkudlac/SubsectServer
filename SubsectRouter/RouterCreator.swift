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

            let jray = SQLHelper().getMenu(funcId: request.parameters["funcid"]!)
            print("jray : \(jray.rawString(options: [])!)" )
            do {
               try response.send(jray.rawString(options: [])!).end()
            } catch {
               Log.error("Caught an error while sending a response: \(error)")
            }
        }
        
        
        do {
            let serverRoot = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                         appropriateFor: nil, create: false).path
          //  print("Path In Router : \(serverRoot)")
            router.all("/", middleware: StaticFileServer(path: serverRoot))
        } catch {
            print("Failed to get server root")
        }
        
        return router
     }
}
