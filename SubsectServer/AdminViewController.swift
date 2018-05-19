//
//  AdminViewController.swift
//  SubServiOS
//
//  Created by Mark Kudlac on 2018-05-07.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import UIKit


class AdminViewController: UIViewController {

    @IBOutlet weak var hostName: UITextField!
    @IBOutlet weak var hostPassword: UITextField!
    @IBOutlet weak var hostEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("View Admin loaded")
        
        Utilities.setTextFromDefault(field: hostName, valueTag: CONST.hostName)
        Utilities.setTextFromDefault(field: hostPassword, valueTag: CONST.hostPassword)
        Utilities.setTextFromDefault(field: hostEmail, valueTag: CONST.hostEmail)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func hostSubmit(_ sender: UIButton) {
  
        let defaults = UserDefaults.standard
        defaults.set(hostName.text, forKey: CONST.hostName)
        defaults.set(hostPassword.text, forKey: CONST.hostPassword)
        defaults.set(hostEmail.text, forKey: CONST.hostEmail)

        toast(message: "Saved", duration: 1.0)
    }
    

    func toast(message: String, duration: Double) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    
}
