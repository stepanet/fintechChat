//
//  Service.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 05/04/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//  Здесь будут разные сервисы

import Foundation


protocol IModel {
    var pixelBay: PixabayJson? { get set }
    var imageInfoArray: [ImageInfo]? {get set}
}

class Service: IModel {
    
    static let shared = Service()
    
    var imageInfoArray: [ImageInfo]?
    var pixelBay: PixabayJson?
    
    
    //возвращаем время из timestamp
    func dateString(date: Date) -> String {
        let second = date.timeIntervalSince1970
        let timestampDate = Date(timeIntervalSince1970: second)
        let dateFormatter = DateFormatter()
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
    
    func pixelLoadJson() {
        let url = URL(string: "https://pixabay.com/api/?key=12169393-c73621fb8fde92ee029635ac1&q=&image_type=photo&pretty=true&page=1&per_page=18")
        
        DispatchQueue.global().async {
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error == nil {
                    do {
                        self.pixelBay = try JSONDecoder().decode(PixabayJson.self, from: data!)
                        
                        self.imageInfoArray = self.pixelBay!.hits
                        
                    } catch {
                        print("pixelBay load error",error.localizedDescription)
                    }
                    print(self.imageInfoArray!.count)
                }
                }.resume()
        }
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

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleToFill ) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
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
