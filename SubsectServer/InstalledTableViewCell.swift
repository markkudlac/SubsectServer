//
//  InstlledTableViewCell.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-31.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import UIKit

class InstalledTableViewCell: UITableViewCell {

    @IBOutlet weak var installedTitle: UILabel!
    @IBOutlet weak var installedIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
    //    super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
