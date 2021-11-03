//
//  ZDCropRectModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/29.
//

import Foundation
import UIKit

enum ZDTouchPosition{
    
    case leftUp, rightUp, rightDown , leftDown
    
}

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
    
    private var touchBeganPoint: CGPoint?
    
    private var touchMovePoint: CGPoint?
    
    /// 手势缩小裁剪框时的最小大小
    private let rectMineSize: CGSize = CGSize(width: 100, height: 100)
    
    /// 距离边距
    private let edgeInset = UIEdgeInsets(top: 50 + UIDevice.APPTOPSAFEHEIGHT, left: 20, bottom: 70 + UIDevice.APPBOTTOMSAFEHEIGHT, right: 20)
    
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
    
    /// 获取当前需要绘制的裁剪区域
    func getDrawCropRect() -> CGRect {
        return self.cropRect
    }
    
    /// 获取最终需要裁剪的区域
    func getCropRect() -> CGRect {
        return self.newCropRect
    }
    
    func getCropEdgeInset() -> UIEdgeInsets {
        return self.edgeInset
    }
    
    /// 销毁控制器
    func destoryTimer() {
        self.disLink.invalidate()
        self.disLink = nil
    }
    
    /// 判断点击的点是否在所画区域的边框上
    func isCropFrame(_ point: CGPoint) -> Bool {
        return self.getTouchPointPosition(point: point) != nil
    }
    
    func setTouchBeganPoint(_ point: CGPoint?) {
        self.touchBeganPoint = point
    }
    
    func setTouchMovePoint(_ point: CGPoint?) {
        self.touchMovePoint = point
        if let beganPoint = self.touchBeganPoint , let currentPoints = self.touchMovePoint , let position = self.getTouchPointPosition(point: beganPoint) {
            // 手指水平滑动的距离,向右>0
            let touchMoveX = currentPoints.x - beganPoint.x
            // 手指垂直滑动的距离,向下>0
            let touchMoveY = currentPoints.y - beganPoint.y
            switch position {
            case .leftUp , .leftDown:
                // 计算当前的X坐标
                var newX = (self.oldCropRect.origin.x + touchMoveX)
                // 限制左边界
                newX = newX <= edgeInset.left ? edgeInset.left : newX
                // 计算当前宽度
                var newWidth = self.oldCropRect.width - (newX - self.oldCropRect.origin.x)
                // 限制最小宽度
                if newWidth <= rectMineSize.width {
                    newWidth = rectMineSize.width
                    newX = self.cropRect.origin.x
                }
                // 计算当前Y的坐标
                var newY = (self.oldCropRect.origin.y + touchMoveY)
                // 限制上边界
                newY = newY <= edgeInset.top ? edgeInset.top : newY
                // 计算当前高度
                var newHeight = self.oldCropRect.height - (newY - self.oldCropRect.origin.y)
                if position == .leftDown {
                    newY = self.cropRect.origin.y
                    newHeight = self.oldCropRect.height + touchMoveY
                    newHeight = newHeight <= rectMineSize.height ? rectMineSize.height : newHeight
                    if newHeight + newY >= UIDevice.APPSCREENHEIGHT - edgeInset.bottom {
                        newHeight = UIDevice.APPSCREENHEIGHT - edgeInset.bottom - newY
                    }
                }
                if newHeight < rectMineSize.height {
                    newHeight = rectMineSize.height
                    newY = self.cropRect.origin.y
                }
                self.cropRect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
            case .rightUp , .rightDown:
                let newX = self.cropRect.origin.x
                var newWidth = self.oldCropRect.width + touchMoveX
                newWidth = newWidth < rectMineSize.width ? rectMineSize.width : newWidth
                // 限制右边距
                if newX + newWidth > UIDevice.APPSCREENWIDTH - edgeInset.right {
                    newWidth = UIDevice.APPSCREENWIDTH - edgeInset.right - newX
                }
                var newY = (self.oldCropRect.origin.y + touchMoveY)
                newY = newY <= edgeInset.top ? edgeInset.top : newY
                // 计算当前高度
                var newHeight = self.oldCropRect.height - (newY - self.oldCropRect.origin.y)
                if position == .rightDown {
                    newY = self.cropRect.origin.y
                    newHeight = self.oldCropRect.height + touchMoveY
                    newHeight = newHeight <= rectMineSize.height ? rectMineSize.height : newHeight
                    if newHeight + newY >= UIDevice.APPSCREENHEIGHT - edgeInset.bottom {
                        newHeight = UIDevice.APPSCREENHEIGHT - edgeInset.bottom - newY
                    }
                }
                if newHeight < rectMineSize.height {
                    newHeight = rectMineSize.height
                    newY = self.cropRect.origin.y
                }
                self.cropRect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
            }
            
        }else {
            self.oldCropRect = self.cropRect
            self.newCropRect = self.cropRect
        }
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
    }
    
    private func getTouchPointPosition(point: CGPoint) -> ZDTouchPosition? {
        let leftUpPath = UIBezierPath(arcCenter: self.oldCropRect.origin, radius: 20, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        if leftUpPath.contains(point) {
            return .leftUp
        }
        let rightUpPath = UIBezierPath(arcCenter: CGPoint(x: self.oldCropRect.origin.x + self.oldCropRect.width, y: self.oldCropRect.origin.y), radius: 20, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        if rightUpPath.contains(point) {
            return .rightUp
        }
        let rightDownPath = UIBezierPath(arcCenter: CGPoint(x: self.oldCropRect.origin.x + self.oldCropRect.width, y: self.oldCropRect.origin.y + self.oldCropRect.height), radius: 20, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        if rightDownPath.contains(point) {
    
            return .rightDown
        }
        let leftDownPath = UIBezierPath(arcCenter: CGPoint(x: self.oldCropRect.origin.x, y: self.oldCropRect.origin.y + self.oldCropRect.height), radius: 20, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        if leftDownPath.contains(point) {
            return .leftDown
        }
        return nil
    }
}
