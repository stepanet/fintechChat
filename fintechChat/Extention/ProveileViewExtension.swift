//
//  ProveileViewExtension.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 13/03/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import Foundation
import UIKit

extension ProfileViewController {
    
    enum CornerRadius: CGFloat {
        case imageViewAndPhotoBtn = 40
        case editBtn = 5
    }

    func setupUI() {
        
        view.backgroundColor = ThemeManager.currentTheme().backgroundColor

        profileNameTxt.backgroundColor = ThemeManager.currentTheme().backgroundColor
        profileNameTxt.textColor = ThemeManager.currentTheme().titleTextColor

        aboutProfileTextView.backgroundColor = ThemeManager.currentTheme().backgroundColor
        aboutProfileTextView.textColor = ThemeManager.currentTheme().titleTextColor

        profileImageView.layer.cornerRadius = CornerRadius.imageViewAndPhotoBtn.rawValue //radiusUI
        profileImageView.clipsToBounds = true

        takePicturesForProfile.layer.cornerRadius = CornerRadius.imageViewAndPhotoBtn.rawValue
        takePicturesForProfile.clipsToBounds = true
        takePicturesForProfile.backgroundColor = ThemeManager.currentTheme().editBtn

        gcdBtn.layer.cornerRadius = CornerRadius.editBtn.rawValue
        gcdBtn.clipsToBounds = true
        gcdBtn.tintColor = ThemeManager.currentTheme().titleTextColor
        gcdBtn.layer.borderWidth = 1
        gcdBtn.layer.borderColor = ThemeManager.currentTheme().titleTextColor.cgColor//UIColor.black.cgColor
        gcdBtn.backgroundColor = ThemeManager.currentTheme().backgroundColor

        editBtn.layer.cornerRadius = CornerRadius.editBtn.rawValue
        editBtn.clipsToBounds = true
        editBtn.tintColor = ThemeManager.currentTheme().titleTextColor
        editBtn.layer.borderWidth = 1
        editBtn.layer.borderColor = ThemeManager.currentTheme().titleTextColor.cgColor
        editBtn.backgroundColor = ThemeManager.currentTheme().backgroundColor
    }

}
