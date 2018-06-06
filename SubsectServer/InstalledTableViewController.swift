//
//  InstalledTableViewController.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-31.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import UIKit
import SwiftyJSON


class InstalledTableViewController: UITableViewController {

    private var appList : [JSON]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        getInstalledList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CONST.rowCount
    }
    
/*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let curCell = tableView.cellForRow(at: indexPath) as! InstalledTableViewCell
        print("Row tapped id : \(curCell.tag)")

    }
   */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdent = "InstalledTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent, for: indexPath) as? InstalledTableViewCell
        
        if cell == nil {
            print("The dequeued cell is not an instance of InstalledTableViewCell.")
        }
        
        if (appList != nil && indexPath.row < appList.count){
           
            cell!.tag = appList[indexPath.row]["id"].int!
            cell!.installedTitle.text = appList[indexPath.row]["title"].string
            
            var str64 = appList[indexPath.row]["icon"].string
            str64 = str64!.replacingOccurrences(of: "data:image/png;base64,", with: "")
            
            let data: Data = Data(base64Encoded: str64!, options: .ignoreUnknownCharacters)!
            // turn  Decoded String into Data
            cell!.installedIcon.image = UIImage(data: data as Data)
 
        } else {
            cell!.installedTitle.text = ""
            cell!.installedIcon.image = nil
        }
        
        return cell!
    }
    

    func getInstalledList() {
        
        appList = SQLHelper(dbName: CONST.dbsubServ).queryDB(query: CONST.tableRegistry, args: JSON.null, limits: JSON.null, funcId: "-1")
        
        let count :JSON = appList.removeFirst()
        print("appList count : \(count[CONST.argsDb].int!)")
        
        if count[CONST.argsReturn].bool! {
            if count[CONST.argsDb].int! > 0 {
                tableView.reloadData()
            }
        } else {
            print("Registry error")
        }
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return appList != nil && indexPath.row < appList.count
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           
            
            let alert = UIAlertController(title: "Uninstall", message: "Would you like to uninstall \(appList[indexPath.row]["title"].string!)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.uninstallApp(indexPath: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    func uninstallApp(indexPath :IndexPath){
        
        // Delete the row from the data source
        
      //  print("Tapped built in delete : \(indexPath)")
        
        if removeApp(registryId: appList[indexPath.row]["id"].int!) {
            appList.remove(at: indexPath.row)
            
            let indexInsert = IndexPath(item: CONST.rowCount-1, section: 0)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.insertRows(at: [indexInsert], with: .bottom)
            tableView.endUpdates()
            tableView.reloadData()
        }
    }
    
    
    private func removeApp(registryId :Int) -> Bool{
    
        /*
 delete registry. permissions, types, install, db
 */
        return true
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
