//
//  Utility.swift
//  SubServiOS
//
//  Created by Mark Kudlac on 2018-05-09.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import Foundation
import UIKit


class Utilities {
    
    static func setTextFromDefault(field: UITextField, valueTag: String) {
        
        if let fieldValue:String = UserDefaults.standard.string(forKey: valueTag) {
            field.text = fieldValue
        } else {
            field.text = ""
        }
    }

}
