//
//  ProductCell.swift
//  ECommerceProject
//
//  Created by Mohd Farhan Khan on 7/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {

    @IBOutlet weak var variantsScrollView: UIScrollView!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var orderCountLabel: UILabel!
    @IBOutlet weak var shareCountLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    @IBOutlet weak var addedDateLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
