//
//  MessageTableViewCell.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 23/02/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var view: UIView!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTheme()
    }
    
    
    fileprivate func setupTheme() {
        
        messageText.layer.cornerRadius = 5
        messageText.clipsToBounds = true
        self.view.backgroundColor = ThemeManager.currentTheme().backgroundColor
        self.messageText.backgroundColor = ThemeManager.currentTheme().backgroundColor
        self.messageText.textColor = ThemeManager.currentTheme().titleTextColor
    }


}
