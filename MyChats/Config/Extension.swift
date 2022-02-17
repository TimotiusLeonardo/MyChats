//
//  Extension.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 05/02/22.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()


extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIImageView {
    func loadImageUsingCacheWithUrlString(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        // Check cache for image first
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if error != nil {
                print(error?.localizedDescription ?? "Error Getting Profile Image Data")
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data else {
                    return
                }
                
                self.image = UIImage(data: data)
                
                imageCache.setObject(UIImage(data: data) ?? UIImage(), forKey:  NSString(string: urlString))
            }
        }.resume()
    }
}
