//
//  HelpViewController.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-31.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

        var helpTarget = CONST.defaultHelp
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("In Help controller, helpTarget : \(helpTarget)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
