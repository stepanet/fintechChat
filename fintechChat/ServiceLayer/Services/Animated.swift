//
//  Animated.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 21/04/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import Foundation

class Animated {
    
    static let animated = Animated()
    
    let imageTinkoffView: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "tinkoff"))
        image.frame = CGRect(x: 0 , y: 0, width: 50, height: 50)
        image.layer.cornerRadius = 25
        image.clipsToBounds = true
        //image.contentMode = .scaleToFit
        return image
    }()
    
    func animatedTableView(tableView: UITableView) {
        //let tableView = UITableView()
        
        tableView.reloadData()
        tableView.backgroundColor = .white
        let cells = tableView.visibleCells
        let tableViewHeigth = tableView.bounds.size.height
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeigth)
        }
        var delayCounter = 0.00
        for cell in cells {
            UIView.animate(withDuration: 1, delay: delayCounter * 0.05, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
        
    }
    
    func animateImg(image: UIImageView, view: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .repeat, animations: {
            image.frame = CGRect(x: Int.random(in: 0..<Int(view.bounds.width)), y: Int.random(in: 0..<Int(view.bounds.height)), width: 50, height: 50)
        }, completion: nil)
    }
    
    
    func labelAnimation(_ label: UILabel, enabled: Bool) {
        if enabled {
            UIView.animate(withDuration: 1, animations: { () -> Void in
                label.textColor = UIColor.green
                label.transform = CGAffineTransform(scaleX: 1.10,
                                                    y: 1.10)
            })
        } else {
            UIView.animate(withDuration: 1, animations: { () -> Void in
                label.textColor = UIColor.black
                label.transform = CGAffineTransform(scaleX: 1.0,
                                                y: 1.0)
            })
        }
    }

    
}

extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func scale() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 0.95
        pulse.toValue = 1.15
        //pulse.autoreverses = true
        //pulse.repeatCount = 2
        //pulse.initialVelocity = 0.5
        //pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
    }
    
    
    func changeColor(_ button: UIButton, state: Bool) {
        UIView.animate(withDuration: 0.5) {
            if state {
                button.backgroundColor = .green
                button.titleLabel?.textColor = .white
                button.isEnabled = true
                button.scale()
            } else {
                button.backgroundColor = .gray
                button.titleLabel?.textColor = .darkGray
                button.isEnabled = false
                button.scale()
            }
        }
    }
    
    func shake() {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }
}
