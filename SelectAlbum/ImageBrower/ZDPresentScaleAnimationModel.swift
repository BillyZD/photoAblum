//
//  ZDPresentScaleAnimationModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/20.
//

import Foundation

/**
 *  present,自定义弹出动画
 */
class ZDPresentScaleAnimationModel: NSObject , UIViewControllerAnimatedTransitioning {
    
    private var startRect: CGRect?
    
    /**
     *  设置需要放大的动画区域
     */
    func setStartAnimationRect(_ rect: CGRect?) {
        self.startRect = rect
    }
    
    /// 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    /// 实现自定义动画
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toVC = transitionContext.viewController(forKey: .to)  {
            let containerView = transitionContext.containerView
            containerView.addSubview(toVC.view)
            let initialFrame = startRect ?? CGRect(x: (containerView.frame.size.width - 100)/2, y:  (containerView.frame.size.height - 100)/2, width: 100, height: 100)
            let finalFrame = transitionContext.finalFrame(for: toVC)
            let duration:TimeInterval = self.transitionDuration(using: transitionContext)
            toVC.view.center = CGPoint.init(x: initialFrame.origin.x + initialFrame.size.width/2, y: initialFrame.origin.y + initialFrame.size.height/2)
            toVC.view.transform = CGAffineTransform.init(scaleX: initialFrame.size.width/finalFrame.size.width, y: initialFrame.size.height/finalFrame.size.height)
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .layoutSubviews, animations: {
                toVC.view.center = CGPoint.init(x: finalFrame.origin.x + finalFrame.size.width/2, y: finalFrame.origin.y + finalFrame.size.height/2)
                toVC.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }) { finished in
                transitionContext.completeTransition(true)
            }
        }
        
    }
    
    
}
