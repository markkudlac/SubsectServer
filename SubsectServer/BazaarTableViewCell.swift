//
//  BazaarTableViewCell.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-21.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import UIKit

class BazaarTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var appTitle: UIButton!
    @IBOutlet weak var appIcon: UIImageView!
    
   // @IBOutlet weak var appCell: BazaarTableViewCell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
