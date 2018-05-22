//
//  BazaarTableViewController.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-21.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import UIKit
import SwiftyJSON

class BazaarTableViewController: UITableViewController {
    
    
    private var xdataTask: URLSessionDataTask?
    private var appList : JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Bazaar"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
            let cellIdent = "BazaarTableViewCell"
         let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent, for: indexPath) as? BazaarTableViewCell
         
         if cell == nil {
            print("The dequeued cell is not an instance of BazaarTableViewCell.")
        }

        if (appList != nil && indexPath.row < appList.count){
            cell!.appTitle.setTitle(appList[indexPath.row]["pkgname"].string, for: .normal)
            cell!.appTitle.tag = indexPath.row
            
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
        
        if var urlComponents = URLComponents(string: "http://192.168.2.60:3000/api/listapps") {
            
            guard let url = urlComponents.url else { return }
            
            xdataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer {
                    print("In defer statement")
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
    
    
}
