//
//  ZDPresentDissAnimationModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/21.
//

import Foundation
import UIKit

protocol ZDDissAnimationProtocol: UIViewController {
    
    func getDissAnimationView() -> UIView?
    
    func getDissAnimationRect() -> CGRect?
    
}

extension ZDDissAnimationProtocol {
    
    func getDissAnimationView() -> UIView? { return nil }
    
    func getDissAnimationRect() -> CGRect? { return nil }
}


class ZDPresentDissAnimationModel: NSObject , UIViewControllerAnimatedTransitioning {
    
    private var finilaRect: CGRect = CGRect(x: (UIDevice.APPSCREENWIDTH)/2, y:UIDevice.APPSCREENHEIGHT, width: 0, height: 0)
    
    private weak var animationView: UIView?
    
    private weak var delegate: ZDDissAnimationProtocol?

    func setDelegate(_ delegate: ZDDissAnimationProtocol?) {
        self.delegate = delegate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewController(forKey: .from) {
            fromVC.view.alpha = 0.0
            var snapshotView: UIView?
            var scaleRatio: CGFloat = 1.0
            if let _animaitonView = self.delegate?.getDissAnimationView() {
                snapshotView = _animaitonView //_animaitonView.snapshotView(afterScreenUpdates: false)
                snapshotView?.layer.zPosition = 30
                scaleRatio = fromVC.view.frame.size.width/_animaitonView.frame.size.width
            }else {
                snapshotView = fromVC.view.snapshotView(afterScreenUpdates: false)
                scaleRatio = fromVC.view.frame.size.width/UIDevice.APPSCREENWIDTH
            }
            guard snapshotView != nil  else {
                transitionContext.finishInteractiveTransition()
                transitionContext.completeTransition(true)
                return
            }
            if let _rect = self.delegate?.getDissAnimationRect(){
                self.finilaRect = _rect
            }
            snapshotView?.contentMode = .scaleAspectFill
            snapshotView?.clipsToBounds = true
            let duration = self.transitionDuration(using: transitionContext)
            let containerView = transitionContext.containerView
            containerView.addSubview(snapshotView!)
           
            snapshotView?.center = fromVC.view.center
            snapshotView?.transform = CGAffineTransform.init(scaleX: scaleRatio, y: scaleRatio)
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


