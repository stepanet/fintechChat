//
//  SettingsTableViewController.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 05/03/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet var imageCell: UIImageView!
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var cell: UITableViewCell!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    @IBAction func closeView(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
           
            self.performSegue(withIdentifier: "ColorThemeView", sender: self)
        }
    }
    
    override func viewWillLayoutSubviews() {
                themeSetup()
    }
    
    fileprivate func themeSetup() {
       
        contentView.backgroundColor = ThemeManager.currentTheme().backgroundColor
        tableView.backgroundColor = ThemeManager.currentTheme().backgroundColor
        titleLbl.backgroundColor = ThemeManager.currentTheme().backgroundColor
        titleLbl.textColor = ThemeManager.currentTheme().titleTextColor

    }
}
