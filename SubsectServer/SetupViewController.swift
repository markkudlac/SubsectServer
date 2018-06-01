//
//  SetupViewController.swift
//  SubServiOS
//
//  Created by Mark Kudlac on 2018-05-09.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {

    @IBOutlet weak var alternateServer: UITextField!
    
    @IBOutlet weak var selectServer: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Utilities.setTextFromDefault(field: alternateServer, valueTag: CONST.alternateServer)
        
        if Utilities.useDefaultServer(){
            selectServer.setOn(true, animated: false)
        } else {
            selectServer.setOn(false, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is HelpViewController
        {
            let vc = segue.destination as? HelpViewController
            vc?.helpTarget = CONST.setupHelp
        }
    }
    
    
    
    @IBAction func modifyAddress(_ sender: Any) {
        
        UserDefaults.standard.set(alternateServer.text, forKey: CONST.alternateServer)
    }
    
    
    @IBAction func defaultServer(_ sender: UISwitch) {
        
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: CONST.selectServer)
        } else {
            UserDefaults.standard.set(false, forKey: CONST.selectServer)
        }
        
    }
}
