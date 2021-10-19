//
//  String+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import Foundation
import UIKit

extension String {
    
    func toImage() -> UIImage? {
        return UIImage(named: self)
    }

}

extension String {
    
    private var flagTag: Int {
        return 4288764
    }
    
    func showToWindow(delay: TimeInterval = 2) {
        guard !self.isEmpty else { return }
        DispatchQueue.main.async {
            if let containerView = UIDevice.APPWINDOW.subviews.first(where: {$0.tag == flagTag}) {
                containerView.isHidden = true
                containerView.removeFromSuperview()
                self.showToWindow(delay: delay)
            }else {
                let lab = UILabel() ; lab.translatesAutoresizingMaskIntoConstraints = false
                lab.font = UIFont.systemFont(ofSize: 16) ; lab.textColor = UIColor.white
                lab.numberOfLines = 0
                lab.text = self
                let containerView = UIView() ; containerView.translatesAutoresizingMaskIntoConstraints = false
                containerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                containerView.layer.cornerRadius = 8 ; containerView.layer.masksToBounds = true
                containerView.tag = flagTag
                containerView.addSubview(lab)
                let vd: [String: UIView] = ["lab": lab]
                containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[lab]-|", options: [], metrics: nil, views: vd))
                containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[lab(>=20)]-5-|", options: [], metrics: nil, views: vd))
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                    containerView.isHidden = true
                    containerView.removeFromSuperview()
                }
                UIDevice.APPWINDOW.addSubview(containerView)
                containerView.centerXAnchor.constraint(equalTo: UIDevice.APPWINDOW.centerXAnchor, constant: 0).isActive = true
                containerView.centerYAnchor.constraint(equalTo: UIDevice.APPWINDOW.centerYAnchor, constant: 0).isActive = true
                containerView.heightAnchor.constraint(lessThanOrEqualToConstant: UIDevice.APPSCREENHEIGHT - 300).isActive = true
                containerView.widthAnchor.constraint(lessThanOrEqualToConstant: UIDevice.APPSCREENWIDTH - 50).isActive = true
                UIDevice.APPWINDOW.bringSubviewToFront(containerView)
            }
        }
        
    }
    
}
