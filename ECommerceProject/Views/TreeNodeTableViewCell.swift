//
//  TreeNodeTableViewCell.swift
//  TreeTableVIewWithSwift
//
//  Created by Mohd Farhan Khan on 7/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit

class TreeNodeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var nodeName: UILabel!
    @IBOutlet weak var nodeIMG: UIImageView!
    @IBOutlet weak var nodeDesc: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
    }
    @IBAction func iconTapped(_ sender: Any) {
       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "iconChanged"), object: self, userInfo: nil)
        
    }
    
}
