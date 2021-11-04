//
//  ZDCropImageManager.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/11/4.
//

import Foundation


class ZDCropImageManager: NSObject {
    
    /// 裁剪样式
    enum ZDCropStyle {
        
        /// 固定比例1:1,16:9,4:3
        case fixedScale
        
        /// 拖动裁剪框，设置比例
        case dragScale
    }
    
    static let manager: ZDCropImageManager = ZDCropImageManager()
    
    /// 裁剪样式
    var cropStyle = ZDCropStyle.fixedScale
    
    private (set) var rectMineSize = CGSize(width: 100, height: 100)
    
    private (set) var cropMinZoomSale: CGFloat = 1.0
    
    private (set) var cropMaxZoomSale: CGFloat = 3.0
    
    private (set) var cropMineEdgInset =  UIEdgeInsets(top: 50 + UIDevice.APPTOPSAFEHEIGHT, left: 20, bottom: 70 + UIDevice.APPBOTTOMSAFEHEIGHT, right: 20)
    
    /// 默认裁剪框
    private (set) var defauleCropRect: CGRect = CGRect(x: 20, y: (UIDevice.APPSCREENHEIGHT - (UIDevice.APPSCREENWIDTH - 40))/2, width: UIDevice.APPSCREENWIDTH - 40, height: UIDevice.APPSCREENWIDTH - 40)
    
    private override init() {}
    
    override func copy() -> Any {
        return ZDCropImageManager.manager
    }

    override func mutableCopy() -> Any {
        return ZDCropImageManager.manager
    }
    
}

extension ZDCropImageManager {
    
    @discardableResult
    static func setDefaleCropRect(_ cropRect: CGRect) -> Bool {
        let res = self.isAllowSetCrop(cropRect)
        if res{
            self.manager.defauleCropRect = cropRect
        }
        return res
    }

    
}

extension ZDCropImageManager {
    
    private static func isAllowSetCrop(_ newCrop: CGRect) -> Bool {
        if newCrop.origin.x < self.manager.cropMineEdgInset.left || newCrop.origin.y < self.manager.cropMineEdgInset.top {
            return false
        }
        if newCrop.origin.x + newCrop.width > UIDevice.APPSCREENWIDTH - self.manager.cropMineEdgInset.right || newCrop.origin.y + newCrop.height > UIDevice.APPSCREENHEIGHT - self.manager.cropMineEdgInset.bottom {
            return false
        }
        return true
    }
}
