//
//  UIImage+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit

extension UIImage {
    
    /// 获取指定大小的图片
    func scaleImage( size to: CGSize) -> UIImage? {
        if self.size.width > size.width {
            UIGraphicsBeginImageContext(size)
            self.draw(in: CGRect(origin: CGPoint.zero, size: size))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }else {
            return self
        }
    }
    
}
