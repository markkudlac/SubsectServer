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
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
      //This gets called on each view
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
            cell!.installedTitle.text = appList[indexPath.row][CONST.fieldTitle].string
            
            var str64 = appList[indexPath.row][CONST.fieldIcon].string
            str64 = str64!.replacingOccurrences(of: "data:image/png;base64,", with: "")
            
            let data: Data = Data(base64Encoded: str64!, options: .ignoreUnknownCharacters)!
            // turn  Decoded String into Data
            cell!.installedIcon.image = UIImage(data: data as Data)
            
            cell!.installedStatus.text = appList[indexPath.row][CONST.fieldStatus].string
 
        } else {
            cell!.installedTitle.text = ""
            cell!.installedIcon.image = nil
            cell!.installedStatus.text = ""
        }
        
        return cell!
    }
    

    func getInstalledList() {
        
        appList = SQLHelper(dbName: CONST.dbsubServ).queryDB(query: CONST.tableRegistry, args: JSON.null, limits: JSON.null, funcId: nil)
        
        let count :JSON = appList.removeFirst()
// print("appList count : \(count[CONST.argsDb].int!)  funcId : \(count[CONST.argsFuncId].string!)")
        
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
        
        if removeApp(registryId: appList[indexPath.row][CONST.fieldId].int!, dbName: appList[indexPath.row][CONST.fieldType].string! + appList[indexPath.row][CONST.fieldApp].string!, appName: appList[indexPath.row][CONST.fieldApp].string!) {
            appList.remove(at: indexPath.row)
            
            let indexInsert = IndexPath(item: CONST.rowCount-1, section: 0)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.insertRows(at: [indexInsert], with: .bottom)
            tableView.endUpdates()
            tableView.reloadData()
        }
    }
    
    
    private func removeApp(registryId :Int, dbName :String, appName :String) -> Bool{
 
        // Make best effort on deletes. This is restartable
        
        var rtn = SQLHelper(dbName: CONST.dbsubServ).updateDB(tableName: CONST.tableRegistry, data: JSON([CONST.fieldStatus : "D"]), query: "\(CONST.fieldId) = \(registryId)", args: JSON.null, funcId: nil)
        
        if !rtn[0][CONST.argsReturn].bool! || rtn[0][CONST.argsDb].int! <= 0 {
           print("Registry update failed : \(rtn[0][CONST.argsReturn].bool!)")
            return false
        }
        
        
        rtn = SQLHelper(dbName: CONST.dbsubServ).queryDB(query: CONST.tableSecure, args: JSON([CONST.fieldDbName : dbName]), limits: JSON.null, funcId: nil)
        
        rtn.removeFirst()
        for element in rtn {
            Utilities.removeSchemaTypes(dbName: dbName, tableName: element[CONST.fieldTableName].string!)
        }

        rtn = SQLHelper(dbName: CONST.dbsubServ).removeDB(tableName: CONST.tableSecure, query: "", args: JSON([CONST.fieldDbName : dbName]), funcId: nil)
 
// print("rtn delete permissions rtn : \(rtn[0][CONST.argsReturn].bool!)  count : \(rtn[0][CONST.argsDb].int!)")
        
        do {
            let appsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(CONST.apps + Utilities.getDirectoryFromDb(dbType: dbName)).path
            
            try FileManager.default.removeItem(atPath: appsDirectory + "/" + appName)
        } catch {
            print("Error: App directory removal failed")
        }
        
        do {
            let dbDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(CONST.dbDirectory).path
            
            try FileManager.default.removeItem(atPath: dbDirectory + "/" + dbName)
        } catch {
            print("Error: DB directory removal failed")
        }
        
        rtn = SQLHelper(dbName: CONST.dbsubServ).removeDB(tableName: CONST.tableRegistry, query: "", args: JSON([CONST.fieldId : registryId]), funcId: nil)
        
// print("rtn delete registry rtn : \(rtn[0][CONST.argsReturn].bool!)  count : \(rtn[0][CONST.argsDb].int!)")
        
        return rtn[0][CONST.argsReturn].bool! && rtn[0][CONST.argsDb].int! > 0
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
