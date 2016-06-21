//
//  PurchaseTacsCell.swift
//  Tac!
//
//  Created by Andrew Fashion on 8/4/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit

protocol PurchaseCellDelegate {
    func purchaseButtonTapped(cell: PurchaseTacsCell)
}

class PurchaseTacsCell: UITableViewCell {

    @IBOutlet weak var pieceOne: UIImageView!
    @IBOutlet weak var pieceTwo: UIImageView!
    @IBOutlet weak var pieceThree: UIImageView!
    @IBOutlet weak var pieceFour: UIImageView!
    @IBOutlet weak var payForButton: DesignableButton!
    
    var delegate: PurchaseCellDelegate?
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let englishTranslate = userDefaults.objectForKey("englishTranslate") as? Bool {
            if englishTranslate == true {
                payForButton.alpha = 1
            } else {
                payForButton.alpha = 0
            }
        }
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buyButtonPressed(sender: AnyObject) {
        delegate?.purchaseButtonTapped(self)
        //NSNotificationCenter.defaultCenter().postNotificationName("BuyTacSet", object: nil)
    }
    
}
