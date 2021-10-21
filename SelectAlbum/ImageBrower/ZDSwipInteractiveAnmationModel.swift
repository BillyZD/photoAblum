//
//  ZDSwipInteractiveAnmationModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/21.
//

import Foundation
import UIKit

class ZDSwipInteractiveAnmationModel: UIPercentDrivenInteractiveTransition {
    
    private (set) var isInteracting: Bool = false
    
    private weak var presrntVC: UIViewController?
    
    private var controllerCenterPoint: CGPoint = CGPoint.zero

    func presentViewController(viewController: UIViewController) {
        self.presrntVC = viewController
        self.controllerCenterPoint = viewController.view.center
        self.presrntVC?.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlerTapGesture(gestureRecognizer:))))
    }
    
    override var completionSpeed: CGFloat {
        set{}
        get{
            return 1 - self.completionSpeed
        }
    }
    
    @objc private func handlerTapGesture(gestureRecognizer:UIPanGestureRecognizer) {
        let superView = gestureRecognizer.view?.superview
        superView?.backgroundColor = UIColor.black
        presrntVC?.view.backgroundColor = UIColor.clear
        let translation = gestureRecognizer.translation(in: superView)
        // 只向下的滑动
        if !isInteracting {
            if (translation.x == 0 && translation.y == 0) || (abs(translation.x) > 1) || (translation.y < 0) {
                self.presrntVC?.view.center = CGPoint.init(x: UIDevice.APPSCREENWIDTH / 2, y: UIDevice.APPSCREENHEIGHT / 2)
                self.presrntVC?.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                return
            }
        }
        switch gestureRecognizer.state {
        case .began:
            isInteracting = true
            break
        case .changed:
            var progress:CGFloat = translation.y / UIDevice.APPSCREENHEIGHT
            progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
            
            let ratio:CGFloat = 1.0 - (progress * 0.5)
            presrntVC?.view.center = CGPoint.init(x: controllerCenterPoint.x + translation.x * ratio, y: controllerCenterPoint.y + translation.y * ratio)
            presrntVC?.view.transform = CGAffineTransform.init(scaleX: ratio, y: ratio)
            superView?.backgroundColor = UIColor.black.withAlphaComponent( 1 - progress)
            update(progress)
            break
        default:
            var progress:CGFloat = translation.y / UIDevice.APPSCREENHEIGHT
            progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
            superView?.backgroundColor = UIColor.black.withAlphaComponent( 1 - progress)
            if progress < 0.3 {
                UIView.animate(withDuration: TimeInterval(progress), delay: 0.0, options: .curveEaseOut, animations: {
                    self.presrntVC?.view.center = CGPoint.init(x: UIDevice.APPSCREENWIDTH / 2, y: UIDevice.APPSCREENHEIGHT / 2)
                    self.presrntVC?.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                    superView?.backgroundColor = UIColor.black.withAlphaComponent(1)
                }) { finished in
                    self.isInteracting = false
                    self.cancel()
                    superView?.backgroundColor = UIColor.clear
                    self.presrntVC?.view.backgroundColor = UIColor.black
                }
            }else {
                isInteracting = false
                finish()
                presrntVC?.dismiss(animated: true, completion: nil)
                superView?.backgroundColor = UIColor.black.withAlphaComponent(0)
                presrntVC?.view.backgroundColor = UIColor.black
            }
            break
        }
    }
    
}
