//
//  MyTacsCell.swift
//  Tac!
//
//  Created by Andrew Fashion on 8/4/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit

protocol MyTacsDelegate {
    func didTapFingerCell(cell: MyTacsCell)
}

class MyTacsCell: UITableViewCell {
    
    @IBOutlet weak var fingerImageView: DesignableImageView!
    @IBOutlet weak var xImageView: UIImageView!
    @IBOutlet weak var oImageView: UIImageView!
    
    var setName: String?
    
    var delegate: MyTacsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        if let delegate = delegate {
            delegate.didTapFingerCell(self)
        }
    }
    
}
