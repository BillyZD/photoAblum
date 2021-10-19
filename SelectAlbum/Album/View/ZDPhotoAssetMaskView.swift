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
        label.backgroundColor = UIColor(hexString: "#FF813B")
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.isHidden = true
        label.isUserInteractionEnabled = true
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
        label.bounds = CGRect(x: 0, y: 0, width: 22, height: 22)
        return label
    }()
    
    private let selectImageView: UIImageView = {
        let imageView = UIImageView(image: "unselect_circle".toImage())
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var tapRightBadgValueHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.addSubview(selectImageView)
        self.addSubview(rightBadgValueLab)
        let vd: [String: UIView] = ["rightBadgValueLab": rightBadgValueLab , "selectImageView": selectImageView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[rightBadgValueLab(22)]-6-|", options: [], metrics: nil, views: vd))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[selectImageView(22)]-6-|", options: [], metrics: nil, views: vd))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[rightBadgValueLab(22)]", options: [], metrics: nil, views: vd))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[selectImageView(22)]", options: [], metrics: nil, views: vd))
        rightBadgValueLab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapRightBadgValue)))
        selectImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapRightBadgValue)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRightBagdValue(_ index: Int?) {
        if let value = index {
            self.rightBadgValueLab.isHidden = false
            self.selectImageView.isHidden = true
            self.rightBadgValueLab.text = "\(value)"
        }else {
            self.rightBadgValueLab.text = nil
            self.rightBadgValueLab.isHidden = true
            self.selectImageView.isHidden = false
        }
    }
    
    func startSelectAnimation() {
        self.rightBadgValueLab.addScaleBigerAnimation()
    }
    
    func handleTapRightBadgValue(handler: (() -> Void)?) {
        tapRightBadgValueHandler = handler
    }
    
    
    @objc private func tapRightBadgValue() {
        tapRightBadgValueHandler?()
    }
}
