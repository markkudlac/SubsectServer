//
//  BazaarTableViewController.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-21.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVHTarGzip


class BazaarTableViewController: UITableViewController {
    
    private var xdataTask: URLSessionDataTask?
    private var appList : JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        //This gets called on each view
        getAppList()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
*/
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CONST.rowCount
    }
    
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let curCell = tableView.cellForRow(at: indexPath) as! BazaarTableViewCell
        
        let alert = UIAlertController(title: "Install", message: "Would you like to install \(curCell.appTitle.currentTitle!)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.installApp(subsectId: curCell.tag)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
         let cellIdent = "BazaarTableViewCell"
         let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent, for: indexPath) as? BazaarTableViewCell
         
         if cell == nil {
            print("The dequeued cell is not an instance of BazaarTableViewCell.")
        }

        if (appList != nil && indexPath.row < appList.count){
            cell!.appTitle.setTitle(appList[indexPath.row]["title"].string, for: .normal)
            cell!.appTitle.tag = appList[indexPath.row]["id"].int!
            
            cell!.tag = appList[indexPath.row]["id"].int!
            
            var str64 = appList[indexPath.row]["icon"].string
            str64 = str64!.replacingOccurrences(of: "data:image/png;base64,", with: "")
          
            let data: Data = Data(base64Encoded: str64!, options: .ignoreUnknownCharacters)!
            // turn  Decoded String into Data
                cell!.appIcon.image = UIImage(data: data as Data)
        } else {
           cell!.appTitle.setTitle("", for: .normal)
        }
 
        return cell!
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func getAppList() {
        
        let defaultSession = URLSession.shared
        var xdownldTask: URLSessionDownloadTask?
        
        xdataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "\(CONST.httpProt)://\(Utilities.getNameServer())\(CONST.apiPath)listapps") {
            
            guard let url = urlComponents.url else { return }
            xdataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer {
            //        print("In defer statement")
                    self.xdataTask = nil
                }
                
                if error != nil {
                    print ("DataTask error: " + error!.localizedDescription)
                } else {
                    let response = response as? HTTPURLResponse
                    if response!.statusCode == 200 {
                 //       print("Resonse was 200")
                        self.appList = JSON(data!)
                        if let jerr = self.appList["error"]["code"].string {
                            print("JSON Error : \(jerr)")
                        } else {
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.tableView.reloadData()
                            })
                        }
                    } else {
                        print("some response fail : \(response!.statusCode)")
                    }
                }
            }
            xdataTask?.resume()
        }
    }
    
    
    func installApp(subsectId: Int) {
        
        let defaultSession = URLSession.shared
        var xdownldTask: URLSessionDownloadTask?
        
        xdataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "\(CONST.httpProt)://\(Utilities.getNameServer())\(CONST.apiPath)serve/\(subsectId)") {
            
            guard let url = urlComponents.url else { return }
            xdataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer {
                    //        print("In defer statement")
                    self.xdataTask = nil
                }
                
                if error != nil {
                    print ("DataTask error: " + error!.localizedDescription)
                } else {
                    let response = response as? HTTPURLResponse
                    if response!.statusCode == 200 {
                        //       print("Resonse was 200")
                        let appZip = JSON(data!)
                        if let jerr = appZip["error"]["code"].string {
                            print("JSON Error : \(jerr)")
                        } else {
                            print("Got appZip : \(appZip["pkgname"].string!)")
                       
                            if let installDirectory = Initialize.installZip(zipFile: appZip["zipfile"].string!, packageName: appZip["pkgname"].string!, dbType: appZip["dbtype"].string!){
                                
                                print("Install dir is : \(installDirectory)")
                                
                                if SQLHelper(dbName: CONST.dbsubServ).initializeRegistry(app: appZip["pkgname"].string!,
                                            sys: true, icon: appZip["icon"].string!,
                                            subsectId: appZip["id"].int!,
                                            title: appZip["title"].string!,
                                            permissions: appZip["permissions"].string!) {
                                    print("registry entry made")
                            
                                    Initialize.systemTables(packageName: appZip["pkgname"].string!, dbType: appZip["dbtype"].string!)
                                }
                            }
                        }
                    } else {
                        print("some response fail : \(response!.statusCode)")
                    }
                }
            }
            xdataTask?.resume()
        }
    }
    
}


