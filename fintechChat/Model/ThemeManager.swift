//
//  ThemeManager.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 01/03/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit
import Foundation


enum Theme: Int {
    
    case ligth, dark, shampan
    
    var mainColor: UIColor {   //
        switch self {
        case .ligth:
            return UIColor(named: "blackColor")!
        case .dark:
            return UIColor(named: "blackColor")! //whiteColor
        case .shampan:
            return UIColor(named: "blueColor")!
        }
    }

    var barStyle: UIBarStyle {
        switch self {
        case .ligth:
            return .default
        case .dark:
            return .black
        case .shampan:
            return .black
        }
    }
    
    var backgroundColor: UIColor {  //цвет фона
        switch self {
        case .ligth:
            return UIColor(named: "whiteColor")!
        case .dark:
            return UIColor(named: "darkColor")!
        case .shampan:
            return UIColor(named: "littelYellow")!
        }
    }
    
    var secondaryColor: UIColor {  //цвет кнопок навигации
        switch self {
        case .ligth:
            return UIColor(named: "blackColor")! //blackColor
        case .dark:
            return UIColor(named: "whiteColor")!
        case .shampan:
            return UIColor(named: "whiteColor")!

        }
    }
    
    var titleTextColor: UIColor {
        switch self {
        case .ligth:
            return UIColor(named: "blackColor")!
        case .dark:
            return UIColor(named: "whiteColor")!
        case .shampan:
            return UIColor(named: "blueColor")!

        }
    }
    var subtitleTextColor: UIColor {
        switch self {
        case .ligth:
            return UIColor(named: "blackColor")!
        case .dark:
            return UIColor(named: "blackColor")!
        case .shampan:
            return UIColor(named: "blackColor")!

        }
    }
    
    var editBtn: UIColor {
        switch self {
        case .ligth:
            return UIColor(named: "blueColor")!
        case .dark:
            return UIColor(named: "darkColor")!
        case .shampan:
            return UIColor(named: "blueColor")!
            
        }
    }
}

let SelectedThemeKey = "SelectedTheme"


class ThemeManager {

    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .shampan
        }
    }
    
    static func applyTheme(theme: Theme) {
        
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()

        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().tintColor = theme.secondaryColor
        UINavigationBar.appearance().backgroundColor = theme.backgroundColor
        UITabBar.appearance().barStyle = theme.barStyle
    }
}
