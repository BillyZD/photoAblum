//
//  ZDCropRectModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/29.
//

import Foundation


class ZDCropRectModel: NSObject {
    
    /// 画裁剪框的速度
    private var speed: TimeInterval = 1/30
    
    private var progress: TimeInterval = 0.0
    
    /// 裁剪框位置
    private var cropRect: CGRect = UIScreen.main.bounds{
        didSet{
            if oldValue != cropRect {
                self.drawHandler?()
            }
        }
    }

    private var oldCropRect: CGRect = UIScreen.main.bounds
    
    private var newCropRect: CGRect = UIScreen.main.bounds
    
    private var isAnimationing: Bool = false
    
    private var disLink: CADisplayLink!
    
    private var drawHandler: (() -> Void)?
    
    override init() {
        super.init()
        self.disLink = CADisplayLink(target: self, selector: #selector(handleDisLinkAction))
        self.disLink.add(to: RunLoop.current, forMode: .common)
        self.disLink.isPaused = true
    }
   
    deinit {
        ZDLog("deint:ZDCropRectModel")
    }
}

extension ZDCropRectModel {
    
    /// 设置裁剪区域
    func setCropRect(_ rect: CGRect , isAnimation: Bool = true , drawHandler: (() -> Void)?) {
        guard isAnimationing == false , rect != self.cropRect else {
            return
        }
        self.drawHandler = drawHandler
        if self.cropRect == CGRect.zero || !isAnimation {
            self.cropRect = rect
            self.oldCropRect = rect
            self.newCropRect = rect
        }else{
            self.newCropRect = rect
            self.startAnimation()
        }
    }
    
    /// 获取当前绘制的裁剪区域
    func getDrawCropRect() -> CGRect {
        return self.cropRect
    }
    
    /// 销毁控制器
    func destoryTimer() {
        self.disLink.invalidate()
        self.disLink = nil
    }
    
    /// 判断点击的点是否在所画区域的边框上
    func isCropFrame(_ point: CGPoint) -> Bool {
//        // 左上角
//        if point.x <= cropRect.origin.x + 20, point.y <= cropRect.origin.y + 20 , point.x >= cropRect.origin.x - 5  {
//            return true
//        }
//        // 右上角
//        if point.x <= cropRect.origin.x + cropRect.size.width , {
//            return true
//        }
        return true
    }
}


extension ZDCropRectModel {
    
    private func startAnimation() {
        self.disLink.isPaused = false
    }
    
    @objc private func handleDisLinkAction() {
        if progress <= 1 {
            self.calculateDrawFrame()
            self.isAnimationing = true
        }else {
            self.disLink.isPaused = true
            self.isAnimationing = false
            self.cropRect = self.newCropRect
            self.oldCropRect = self.newCropRect
            self.progress = 0.0
        }
        
        progress += speed
    }
    
    private func calculateDrawFrame() {
        let marginX = self.newCropRect.origin.x - self.oldCropRect.origin.x
        let newX = (self.oldCropRect.origin.x + marginX * progress)
        let marginY = self.newCropRect.origin.y - self.oldCropRect.origin.y
        let newY = (self.oldCropRect.origin.y + marginY * progress)
        let marginW = self.newCropRect.size.width - self.oldCropRect.size.width
        let newW = (self.oldCropRect.size.width + marginW * progress)
        let marginH = self.newCropRect.size.height - self.oldCropRect.size.height
        let newH = (self.oldCropRect.size.height + marginH * progress)
        self.cropRect = CGRect(x: newX, y: newY, width: newW, height: newH)
        debugPrint(self.cropRect)
    }
    
}
