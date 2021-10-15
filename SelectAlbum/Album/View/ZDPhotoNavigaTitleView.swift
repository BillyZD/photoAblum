//
//  ZDPhotoNavigaToolView.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/15.
//

import UIKit

class ZDPhotoNavigaTitleView: UIView {
    
    private let albumNameLabel: UILabel = {
        let label = UILabel() ; label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hexString: "#333333") ; label.font = UIFont.systemFont(ofSize: 16)
        label.text = "照片" ; label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = UIImageView(image: "down_triangle".toImage())
    
    private var isSelectState: Bool = false {
        didSet{
            UIView.animate(withDuration: 0.25) {
                if self.isSelectState {
                    self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }else {
                    self.imageView.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
    private var tapHandler: ((Bool) -> Bool)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(hexString: "#F4EEEB")
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(albumNameLabel) ; self.addSubview(imageView)
        let vd: [String: UIView] = ["albumNameLabel": albumNameLabel , "imageView": imageView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-12-[albumNameLabel]-4-[imageView(7)]-12-|", options: [.alignAllCenterY], metrics: nil, views: vd))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[albumNameLabel(26)]-2-|", options: [], metrics: nil, views: vd))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSelfAction)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapSelfAction() {
        if let res = self.tapHandler?(isSelectState) {
            self.isSelectState = res
        }
    }
    
    func handleTapAction(handler: ((Bool) -> Bool)?) {
        self.tapHandler = handler
    }
    
    func setAlbumName(_ name: String?) {
        self.isSelectState = false
        self.albumNameLabel.text = name
        UIView.animate(withDuration: 0.25) {
            self.albumNameLabel.text = name
            self.layoutIfNeeded()
        }
        
    }
    
}
