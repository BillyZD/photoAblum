//
//  ZDPresentDissAnimationModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/21.
//

import Foundation
import UIKit

class ZDPresentDissAnimationModel: NSObject , UIViewControllerAnimatedTransitioning {
    
    private var finilaRect: CGRect = CGRect(x: (UIDevice.APPSCREENWIDTH)/2, y:UIDevice.APPSCREENHEIGHT, width: 0, height: 0)
    
    private weak var animationView: UIView?
    
    private weak var delegate: ZDPresentAnimationProtocol?
    

    func setDelegate(_ delegate: ZDPresentAnimationProtocol?) {
        self.delegate = delegate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewController(forKey: .from) {
            fromVC.view.alpha = 0.0
            var snapshotView: UIView?
            var scaleRatioX: CGFloat = 1.0
            var scaleRatioY: CGFloat = 1.0
            if let _animaitonView = self.delegate?.getAnimationView() {
                snapshotView = _animaitonView.snapshotView(afterScreenUpdates: false)
                snapshotView?.layer.zPosition = 30
                scaleRatioX = fromVC.view.frame.size.width/_animaitonView.frame.size.width
                scaleRatioY = fromVC.view.frame.size.height/_animaitonView.frame.size.height
            }else {
                snapshotView = fromVC.view.snapshotView(afterScreenUpdates: false)
                scaleRatioX = fromVC.view.frame.size.width/UIDevice.APPSCREENWIDTH
                scaleRatioY = fromVC.view.frame.size.height/UIDevice.APPSCREENHEIGHT
            }
            guard snapshotView != nil  else {
                transitionContext.finishInteractiveTransition()
                transitionContext.completeTransition(true)
                return
            }
            if let _rect = self.delegate?.getAnimationRect() {
                self.finilaRect = _rect
            }
            snapshotView?.contentMode = .scaleAspectFill
            snapshotView?.clipsToBounds = true
            let duration = self.transitionDuration(using: transitionContext)
            let containerView = transitionContext.containerView
            containerView.addSubview(snapshotView!)
           
            snapshotView?.center = fromVC.view.center
            snapshotView?.transform = CGAffineTransform.init(scaleX: scaleRatioX, y: scaleRatioY)
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
                snapshotView?.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                snapshotView?.frame = self.finilaRect
            }) { finished in
                transitionContext.finishInteractiveTransition()
                transitionContext.completeTransition(true)
                snapshotView?.removeFromSuperview()
            }
        }
    }
    
    
}


