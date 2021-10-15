//
//  UIView+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/15.
//

import UIKit

extension UIView {
    
    func addScaleBigerAnimation() {
        UIView.animate(withDuration: 0.15, delay: 0,options: [.beginFromCurrentState , .curveEaseInOut]) {
            self.layer.setValue(1.15, forKeyPath: "transform.scale")
        } completion: { (_) in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState , .curveEaseInOut]) {
                self.layer.setValue(0.92, forKeyPath: "transform.scale")
            } completion: { (_) in
                UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState , .curveEaseInOut]) {
                    self.layer.setValue(1.0, forKeyPath: "transform.scale")
                }
            }

        }
    }
    
}
