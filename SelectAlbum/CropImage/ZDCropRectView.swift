//
//  ZDCropImageView.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/29.
//

import Foundation

/**
 *  自定义裁剪框
 */
class ZDCropRectView: UIView {
    
    /// 裁剪框大小
    var cropRect: CGRect {
        return self.cropModel.getCropRect()
    }
    
    /// 完成事件的回调
    var completeCropHandler:((CGRect?) -> Void)?
    
    /// 裁剪框发生变化的回调
    var cropRectChangeHandler: (() -> Void)?
    
    /// 默认裁剪框
    private var defaultCropRect: CGRect = CGRect(x: 20, y: (UIDevice.APPSCREENHEIGHT - (UIDevice.APPSCREENWIDTH - 40))/2, width: UIDevice.APPSCREENWIDTH - 40, height: UIDevice.APPSCREENWIDTH - 40)
    
    private let cropModel = ZDCropRectModel()
    
    private let bottomTool = ZDCropToolView()
    
    convenience init(cropRect: CGRect?) {
        self.init(frame: UIScreen.main.bounds)
        if let _crop = cropRect , self.isAllowSetCropRect(_crop) , self.defaultCropRect != _crop {
            self.defaultCropRect = _crop
            cropModel.setCropRect(defaultCropRect,isAnimation: false) { [weak self] in
                self?.setNeedsDisplay()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        // 设置初始裁剪框
        cropModel.setCropRect(defaultCropRect , isAnimation: true) { [weak self] in
            self?.setNeedsDisplay()
        }
        self.addSubview(bottomTool)
        let vd: [String: UIView] = ["bottomTool": bottomTool]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[bottomTool]|", options: [], metrics: nil, views: vd))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomTool]|", options: [], metrics: nil, views: vd))
        
        bottomTool.completeActionHandler { [weak self] type in
            switch type {
            case .complete:
                self?.completeCropHandler?(self?.cropModel.getDrawCropRect())
            case .cancle:
                self?.completeCropHandler?(nil)
            case .scale1:
                self?.setScale1CropRect()
            case .scale4:
                self?.setScale4CropRect()
            case .scale16:
                self?.setScale16CropRect()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 事件穿透， 只响应button的点击事件
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let superView = super.hitTest(point, with: event)
        if superView is UIButton {
            return superView
        }
        if superView is ZDCropRectView {
            // 判断点击的点，是否在边框周围
            if cropModel.isCropFrame(point) {
                return superView
            }
        }
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.cropModel.setTouchBeganPoint(touches.first?.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.cropModel.setTouchMovePoint(touches.first?.location(in: self))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.cropModel.setTouchMovePoint(nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.cropModel.setTouchMovePoint(nil)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            let drawRect = cropModel.getDrawCropRect()
            UIColor.black.withAlphaComponent(0.5).setFill()
            let path = UIBezierPath(rect: UIScreen.main.bounds)
            path.append(UIBezierPath(rect: drawRect))
            context.setStrokeColor(UIColor.white.cgColor)
            context.addPath(path.cgPath)
            context.fillPath(using: CoreGraphics.CGPathFillRule.evenOdd)
            // 添加边框
            context.setLineWidth(1)
            context.setStrokeColor(UIColor.white.cgColor)
            context.addRect(drawRect)
            context.strokePath()
            // 绘制4角
            if drawRect.width > 50 , drawRect.height > 50 {
                context.setLineWidth(3)
                context.setStrokeColor(UIColor.white.cgColor)
                context.move(to: CGPoint(x: drawRect.origin.x, y: drawRect.origin.y + 25))
                context.addLine(to: CGPoint(x: drawRect.origin.x, y:  drawRect.origin.y))
                context.addLine(to: CGPoint(x: drawRect.origin.x + 25, y: drawRect.origin.y))
                let rightPoint = CGPoint(x: drawRect.origin.x + drawRect.size.width - 25, y: drawRect.origin.y)
                context.move(to: rightPoint)
                context.addLine(to: CGPoint(x: rightPoint.x + 25 , y: rightPoint.y))
                context.addLine(to: CGPoint(x: rightPoint.x + 25, y: rightPoint.y + 25))
                let rightDownPoint = CGPoint(x: drawRect.origin.x + drawRect.size.width, y: drawRect.origin.y + drawRect.size.height - 25)
                context.move(to: rightDownPoint)
                context.addLine(to: CGPoint(x: rightDownPoint.x, y: rightDownPoint.y + 25))
                context.addLine(to: CGPoint(x: rightDownPoint.x - 25, y: rightDownPoint.y + 25))
                let downPoint = CGPoint(x: drawRect.origin.x + 25, y: drawRect.origin.y + drawRect.size.height)
                context.move(to: downPoint)
                context.addLine(to: CGPoint(x: downPoint.x - 25, y: downPoint.y))
                context.addLine(to: CGPoint(x: downPoint.x - 25, y:  downPoint.y - 25))
                context.strokePath()
            }
        }
    }
    
    deinit {
        self.cropModel.destoryTimer()
        ZDLog("deinit: ZDCropImageView")
    }
    
    /// 设置默认1:1的裁剪框
    private func setScale1CropRect() {
        if self.cropRect == defaultCropRect {return}
        cropModel.setCropRect(defaultCropRect) { [weak self] in
            self?.setNeedsDisplay()
        }
        cropRectChangeHandler?()
    }
    
    /// 设置默认16:9的裁剪框
    private func setScale16CropRect() {
        let height = self.defaultCropRect.width * 9.0 / 16.0
        let y = (UIDevice.APPSCREENHEIGHT - height)/2
        let newCropRect = CGRect(origin: CGPoint(x: defaultCropRect.origin.x, y: y), size: CGSize(width: defaultCropRect.width, height: height))
        if self.cropRect == newCropRect {return}
        cropModel.setCropRect(newCropRect) { [weak self] in
            self?.setNeedsDisplay()
        }
        cropRectChangeHandler?()
    }
    
    /// 设置默认4:3的裁剪框
    private func setScale4CropRect() {
        let height = self.defaultCropRect.width * 3.0 / 4.0
        let y = (UIDevice.APPSCREENHEIGHT - height)/2
        let newCropRect = CGRect(origin: CGPoint(x:  defaultCropRect.origin.x, y: y), size: CGSize(width: defaultCropRect.width, height: height))
        if self.cropRect == newCropRect {return}
        cropModel.setCropRect(newCropRect) {
            [weak self] in
            self?.setNeedsDisplay()
        }
        cropRectChangeHandler?()
    }
    
    private func isAllowSetCropRect(_ cropRect: CGRect) -> Bool {
        if cropRect.origin.x < 0 ||  cropRect.origin.y < 0 {
            return false
        }
        let edgeinset = self.cropModel.getCropEdgeInset()
        if cropRect.origin.x + cropRect.size.width > UIDevice.APPSCREENWIDTH - edgeinset.left - edgeinset.right || cropRect.origin.y + cropRect.size.height > UIDevice.APPSCREENHEIGHT - edgeinset.top - edgeinset.bottom {
            return false
        }
        return true
        
    }
    
}
