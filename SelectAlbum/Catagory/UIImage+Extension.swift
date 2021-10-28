//
//  UIImage+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit

extension UIImage {
    
    /**
     *  UIKit获取指定宽度，等比的图片
     */
    func scaleImage(_ newWidth: CGFloat) -> UIImage? {
        if size.width > newWidth{
            let newHeight = newWidth * (self.size.height / self.size.width)
            let newSize: CGSize = CGSize(width: newWidth, height: newHeight)
            return scaleImage(newsize: newSize)
        }
        return self
    }
    
    /// 获取指定大小的图片
    func scaleImage(newsize: CGSize) -> UIImage? {
        if self.size.width > newsize.width {
            let render = UIGraphicsImageRenderer(size: newsize)
            return render.image { cnx in
                self.draw(in: CGRect(origin: .zero, size: newsize))
            }
            //  总是会使用 sRGB，因此无法使用宽色域，也无法在不需要的时候节省空间
            //  UIGraphicsBeginImageContext(_newSize)
            //  self.draw(in: CGRect(origin: CGPoint.zero, size: _newSize))
            //  let newImage = UIGraphicsGetImageFromCurrentImageContext()
            //  UIGraphicsEndImageContext()
            //   return newImage
            
        }else {
            return self
        }
    }
    
    /**
     *  向下采样 CoreGraphics CGContext
     */
    static func scaleImage(newWidth: CGFloat , url: URL) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        if let imageSourse = CGImageSourceCreateWithURL((url as CFURL), imageSourceOptions) {
            if let cgImage = CGImageSourceCreateImageAtIndex(imageSourse, 0, nil) {
                var _newHeight = newWidth * (Double(cgImage.height)/Double(cgImage.width))
                var _newWidth = newWidth
                if newWidth <= 0 {
                    _newHeight = Double(cgImage.height)
                    _newWidth = Double(cgImage.width)
                }
                if let context = CGContext(data: nil, width: Int(_newWidth), height: Int(_newHeight), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: cgImage.bytesPerRow, space: cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)! , bitmapInfo: self.normalizeBitmapInfo(oldBitmapInfo: cgImage.bitmapInfo)) {
                    context.interpolationQuality = .high
                    context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: _newWidth, height: _newHeight)))
                    if let inputCGImage = context.makeImage() {
                        return UIImage(cgImage: inputCGImage)
                    }
                }
            }
        }
        return nil
    }
    
    
    static func scaleImage(newsize: CGSize , url: URL) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        if let imageSourse = CGImageSourceCreateWithURL((url as CFURL), imageSourceOptions) {
            if let cgImage = CGImageSourceCreateImageAtIndex(imageSourse, 0, nil) {
                if let context = CGContext(data: nil, width: Int(newsize.width), height: Int(newsize.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: cgImage.bytesPerRow, space: cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)! , bitmapInfo: self.normalizeBitmapInfo(oldBitmapInfo: cgImage.bitmapInfo)) {
                    context.interpolationQuality = .high
                    context.draw(cgImage, in: CGRect(origin: .zero, size: newsize))
                    if let inputCGImage = context.makeImage() {
                        return UIImage(cgImage: inputCGImage)
                    }
                }
            }
        }
        return nil
    }
    
    /// imagIO
    static func getThumbnailImage(newWidth: CGFloat , url: URL) -> UIImage? {
        let imaeSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        if  let imageSource = CGImageSourceCreateWithURL((url as CFURL), imaeSourceOptions) {
            let maxDimensionInPixles = newWidth
            let inputOptins = [kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixles ,
                                kCGImageSourceCreateThumbnailWithTransform: true,
                                kCGImageSourceShouldCacheImmediately: true ,
                                kCGImageSourceCreateThumbnailFromImageAlways: true
            ] as CFDictionary
            if  let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, inputOptins){
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    
    /// 初始化GIF图片
    static func initGIFImage(gifData: Data) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        if let source = CGImageSourceCreateWithData((gifData as CFData), imageSourceOptions) {
            let count = CGImageSourceGetCount(source)
            if count <= 1 {
                return UIImage(data: gifData)
            }
            let interval: Int = 1
            var duration: TimeInterval = 0.0
            var i: Int = 0
            var tempImageArr: [UIImage] = []
            while i < count {
                if let image = CGImageSourceCreateImageAtIndex(source, i, nil){
                    let space = CGColorSpaceCreateDeviceRGB()
                    let contxt = CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: image.bitsPerComponent, bytesPerRow: 0, space: space, bitmapInfo: UIImage.normalizeBitmapInfo(oldBitmapInfo: image.bitmapInfo))
                    contxt?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
                    if let _image = contxt?.makeImage() {
                        tempImageArr.append(UIImage(cgImage: _image, scale: UIScreen.main.scale, orientation: .up))
                    }else {
                        debugPrint("失败")
                    }
                    duration += (TimeInterval(self.frameDurationAtIndex(index: i, soucre: source)))
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
        if frameDuration < 0.02 {
            frameDuration = 0.1
        }
        return frameDuration
    }
    
    static func normalizeBitmapInfo(oldBitmapInfo: CGBitmapInfo) -> UInt32{
        var alphaInfo = oldBitmapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        if alphaInfo == CGImageAlphaInfo.last.rawValue {
            alphaInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        }else if alphaInfo == CGImageAlphaInfo.first.rawValue {
            alphaInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
        }
        var newBitmapInfo = oldBitmapInfo.rawValue & ~CGBitmapInfo.alphaInfoMask.rawValue
        newBitmapInfo |= alphaInfo
        return newBitmapInfo
    }
    
}
