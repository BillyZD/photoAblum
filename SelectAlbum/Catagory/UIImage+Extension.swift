//
//  UIImage+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit

extension UIImage {
    
    /// 获取指定大小的图片
    func scaleImage(size to: CGSize) -> UIImage? {
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
    
    /// 初始化GIF图片
    static func initGIFImage(gifData: Data) -> UIImage? {
        if let source = CGImageSourceCreateWithData((gifData as CFData), nil) {
            let count = CGImageSourceGetCount(source)
            if count <= 1 {
                return UIImage(data: gifData)
            }
            let maxCount: Int = 50
            let interval: Int = max((count + maxCount / 2) / maxCount, 1)
            var duration: TimeInterval = 0.0
            var i: Int = 0
            var tempImageArr: [UIImage] = []
            while i < count {
                if let image = CGImageSourceCreateImageAtIndex(source, i, nil){
                    duration += TimeInterval(self.frameDurationAtIndex(index: i, soucre: source))
                    tempImageArr.append(UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up))
                }
               
                i += interval
            }
            if duration == 0 {
                duration = (1 / 10) * TimeInterval(count)
            }
            return UIImage.animatedImage(with: tempImageArr, duration: duration)
        }
        return UIImage(data: gifData)
    }
    
    private static func frameDurationAtIndex(index: Int , soucre: CGImageSource) -> Float {
        var frameDuration: Float = 0.1
        let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(soucre, index, nil)
        let gifProperties = (cfFrameProperties as? Dictionary<CFString, Any>)?[kCGImagePropertyGIFDictionary] as? [String: Any]
        
        if let delayTimeUnclampedProp = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
            frameDuration = delayTimeUnclampedProp.floatValue
        }
        if frameDuration < 0.011 {
            frameDuration = 0.1
        }
        return frameDuration
    }
    
}
