//
//  Service.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 05/04/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//  Здесь будут разные сервисы

import Foundation


class Service {
    
    static let shared = Service()
    
    //возвращаем время из timestamp
    func dateString(date: Date) -> String {
        let second = date.timeIntervalSince1970
        let timestampDate = Date(timeIntervalSince1970: second)
        let dateFormatter = DateFormatter()
        print(Date(), date)
        if Service.daysBetween(start: Date(), end: date) < 0 {
            dateFormatter.dateFormat = "dd.MM"
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
        
        return dateFormatter.string(from: timestampDate as Date)
    }
    
    
    public static func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
}
}
