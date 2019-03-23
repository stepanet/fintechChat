//
//  ThemesViewController.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 01/03/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    
    let theme = ThemeManager.currentTheme()
    let saveTheme = ReadWriteData.GCDDataManager()
    
    
    @IBOutlet weak var ligthThemeBtn: UIButton!
    @IBOutlet weak var darkThemeBtn: UIButton!
    @IBOutlet weak var shampanThemeBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBtnAndView() //for Krutanoff
        
    }
    
    @IBAction func closeThemeView(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupBtnAndView() {

        
        self.view.backgroundColor = ThemeManager.currentTheme().backgroundColor
        
        ligthThemeBtn.layer.cornerRadius = 5
        darkThemeBtn.layer.cornerRadius = 5
        shampanThemeBtn.layer.cornerRadius = 5
        ligthThemeBtn.clipsToBounds = true
        darkThemeBtn.clipsToBounds = true
        shampanThemeBtn.clipsToBounds = true
        
        ligthThemeBtn.layer.borderWidth = 1
        ligthThemeBtn.layer.borderColor = ThemeManager.currentTheme().subtitleTextColor.cgColor
        
        darkThemeBtn.layer.borderWidth = 1
        darkThemeBtn.layer.borderColor = ThemeManager.currentTheme().titleTextColor.cgColor
        
        shampanThemeBtn.layer.borderWidth = 1
        shampanThemeBtn.layer.borderColor = ThemeManager.currentTheme().subtitleTextColor.cgColor
        
    }
    
    @IBAction func changeThemeAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            print("ligth")
            ThemeManager.applyTheme(theme: .ligth)
            saveTheme.text = ".ligth"
        case 1:
            print("dark")
            ThemeManager.applyTheme(theme: .dark)
            saveTheme.text = ".dark"
        case 2:
            print("shampan")
            ThemeManager.applyTheme(theme: .shampan)
            saveTheme.text = ".shampan"
        default:
            break
        }
        
        saveTheme.queueGlobal.async {
            self.saveTheme.nameOfFile = "theme.txt"
            self.saveTheme.txtWriteFile()
        }


        self.view.backgroundColor = ThemeManager.currentTheme().backgroundColor
    }
    
}
