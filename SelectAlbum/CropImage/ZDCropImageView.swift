//
//  ZDCropImageView.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/29.
//

import Foundation
import UIKit

class ZDCropImageView: UIView {
    
    private let cropModel = ZDCropRectModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        let width = self.frame.size.width - 20
        let height = width
        let cropRect = CGRect(x: 10, y: (self.frame.size.height - height - 100)/2, width: width, height: height)
        cropModel.setCropRect(cropRect) { [weak self] in
            self?.setNeedsDisplay()
        }
        
        let button1 = UIButton(frame: CGRect(x: 40, y: 50, width: 40, height: 40))
        button1.setTitle("4:3", for: .normal)
        button1.setTitleColor(.black, for: .normal)
        button1.setTitleColor(.white, for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(button1)
        button1.addTarget(self, action: #selector(clickFirstButton), for: .touchUpInside)
        
        let button2 = UIButton(frame: CGRect(x: 140, y: 50, width: 40, height: 40))
        button2.setTitle("16:9", for: .normal)
        button2.setTitleColor(.white, for: .normal)
        button2.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(button2)
        button2.addTarget(self, action: #selector(clickSecondButton), for: .touchUpInside)
        
        let button3 = UIButton(frame: CGRect(x: 240, y: 50, width: 40, height: 40))
        button3.setTitle("1:1", for: .normal)
        button3.setTitleColor(.white, for: .normal)
        button3.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(button3)
        button3.addTarget(self, action: #selector(clickThirdButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("bbb")
    }
    
    // 事件穿透， 只响应button的点击事件
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let superView = super.hitTest(point, with: event)
        if superView is UIButton {
            return superView
        }
        if superView is ZDCropImageView {
            // 判断点击的点，是否在边框周围
            if cropModel.isCropFrame(point) {
                return superView
            }
        }
        return nil
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("aaa")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            let drawRect = cropModel.getDrawCropRect()
            UIColor.black.withAlphaComponent(0.5).setFill()
            let path = UIBezierPath(rect: UIScreen.main.bounds)
            path.append(UIBezierPath(rect: drawRect))
            context.addPath(path.cgPath)
            context.fillPath(using: CoreGraphics.CGPathFillRule.evenOdd)
            // 添加边框
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
            context.restoreGState()
        }
    }
    
    deinit {
        self.cropModel.destoryTimer()
        ZDLog("deinit: ZDCropImageView")
    }
    
    @objc func clickFirstButton() {
        let width = self.frame.size.width - 20
        let height = width * 3 / 4
        let cropRect = CGRect(x: 10, y: (self.frame.size.height - height - 100)/2, width: width, height: height)
        cropModel.setCropRect(cropRect) { [weak self] in
            self?.setNeedsDisplay()
        }
    }
    
    @objc func clickSecondButton() {
        let width = self.frame.size.width - 100
        let height = width * 9 / 16
        let cropRect = CGRect(x: 50, y: (self.frame.size.height - height - 100)/2, width: width, height: height)
        cropModel.setCropRect(cropRect) { [weak self] in
            self?.setNeedsDisplay()
        }
    }
    
    @objc func clickThirdButton() {
        let width = self.frame.size.width - 20
        let height = width
        let cropRect = CGRect(x: 10, y: (self.frame.size.height - height - 100)/2, width: width, height: height)
        cropModel.setCropRect(cropRect) { [weak self] in
            self?.setNeedsDisplay()
        }
    }
    
}
