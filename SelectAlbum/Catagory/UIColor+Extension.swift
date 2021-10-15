//
//  UIColor+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/13.
//

import UIKit

extension UIColor{
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var cstr = hexString.trimmingCharacters(in:  CharacterSet.whitespacesAndNewlines).uppercased() as NSString
        if(cstr.length < 6){
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
            return
        }
        if(cstr.hasPrefix("0X")){
            cstr = cstr.substring(from: 2) as NSString
        }
        if(cstr.hasPrefix("#")){
            cstr = cstr.substring(from: 1) as NSString
        }
        if(cstr.length != 6){
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
            return
        }
        var range = NSRange.init()
        range.location = 0
        range.length = 2
        let rStr = cstr.substring(with: range)
        range.location = 2
        let gStr = cstr.substring(with: range)
        range.location = 4
        let bStr = cstr.substring(with: range)
        var r :UInt32 = 0x0
        var g :UInt32 = 0x0
        var b :UInt32 = 0x0
        Scanner.init(string: rStr).scanHexInt32(&r)
        Scanner.init(string: gStr).scanHexInt32(&g)
        Scanner.init(string: bStr).scanHexInt32(&b)
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
}
