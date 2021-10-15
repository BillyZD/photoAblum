//
//  ZDPhotoAssetMaskView.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/13.
//

import UIKit

/**
 *  照片列表Cell遮照View
 */
class ZDPhotoAssetMaskView: UIView {
    
    private let rightBadgValueLab: UILabel = {
        let label = UILabel() ; label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return label
    }()
    
    private var tapRightBadgValueHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.addSubview(rightBadgValueLab)
        let vd: [String: UIView] = ["rightBadgValueLab": rightBadgValueLab]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[rightBadgValueLab(24)]-6-|", options: [], metrics: nil, views: vd))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[rightBadgValueLab(24)]", options: [], metrics: nil, views: vd))
        rightBadgValueLab.isUserInteractionEnabled = true
        rightBadgValueLab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapRightBadgValue)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRightBagdValue(_ index: Int?) {
        if let value = index {
            self.rightBadgValueLab.text = "\(value)"
        }else {
            self.rightBadgValueLab.text = nil
        }
    }
    
    func handleTapRightBadgValue(handler: (() -> Void)?) {
        tapRightBadgValueHandler = handler
    }
    
    
    @objc private func tapRightBadgValue() {
        tapRightBadgValueHandler?()
    }
}
