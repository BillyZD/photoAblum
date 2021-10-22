//
//  ZDPresentAnimationModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/20.
//

import Foundation

/**
 *  present动画模型
 */
class ZDPresentAnimationModel: NSObject {
    
    private let scalePresentAnimation = ZDPresentScaleAnimationModel()
    
    private let dissPresentAnimation = ZDPresentDissAnimationModel()
    
    private let swipPresentAnimation = ZDSwipInteractiveAnmationModel()
    
    func presentController(fromVC: UIViewController , toVC: ZDDissAnimationProtocol , rect: CGRect? , isAddSwip: Bool = true) {
        dissPresentAnimation.setDelegate(toVC)
        scalePresentAnimation.setStartAnimationRect(rect)
        if isAddSwip {swipPresentAnimation.presentViewController(viewController: toVC)}
        toVC.transitioningDelegate = self
        toVC.modalPresentationStyle = .overCurrentContext
        fromVC.modalPresentationStyle = .currentContext
        fromVC.present(toVC, animated: true, completion: nil)
    }
    
}

extension ZDPresentAnimationModel: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return scalePresentAnimation
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dissPresentAnimation
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipPresentAnimation.isInteracting ? swipPresentAnimation : nil
    }
    
}
