//
//  ZDPhotoBrowerToolView.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/14.
//

import UIKit

enum ZDBrowerToolActionType{
    case back , completed , selected
}

/**
 *  照片预览界面，底部工具栏
 */
class ZDPhotoPreviewBottomView: UIView {
    
    private let originByteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.white
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton() ; button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("完成", for: .normal) ; button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor(hexString: "#999999")
        button.layer.cornerRadius = 14 ; button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private var completeHandler: ((ZDBrowerToolActionType) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        configMainUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clickCompleteButton() {
        completeHandler?(.completed)
    }
    
}

// MARK: - public API
extension ZDPhotoPreviewBottomView {
    
    /// 设置原图大小
    func setOriginByte(_ byte: Int64) {
        self.originByteLabel.text = "原图(\(Double(byte).getByteCountText()))"
    }
    
    /// 设置完成按钮是否可用
    func isAbleComplete(_ isEnabled: Bool) {
        self.completeButton.isUserInteractionEnabled = isEnabled
        self.completeButton.backgroundColor =  isEnabled ? UIColor(hexString: "#FF813B") : UIColor(hexString: "#999999")
    }
    
    func handleCompleteAction(handler: ((ZDBrowerToolActionType) -> Void)?) {
        self.completeHandler = handler
    }
}

extension ZDPhotoPreviewBottomView {
    
    private func configMainUI() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.addSubview(originByteLabel)
        self.addSubview(completeButton)
        let vd: [String: UIView] = ["originByteLabel": originByteLabel , "completeButton": completeButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[originByteLabel]-(>=10)-[completeButton(58)]-16-|", options: [.alignAllCenterY], metrics: nil, views: vd))
        completeButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        originByteLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -UIDevice.APPBOTTOMSAFEHEIGHT/2).isActive = true
        completeButton.addTarget(self, action: #selector(clickCompleteButton), for: .touchUpInside)
    }
}

/**
 *  照片预览界面，顶部工具栏
 */
class ZDPhotoPreviewTopView: UIView {
    
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
    
    private let backButton: UIButton = {
        let button = UIButton() ; button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage("album_back_white".toImage(), for: .normal)
        return button
    }()
    
    private var backHandler: ((ZDBrowerToolActionType) -> Void)?
    
    private var tapRightBadgValueHandler: ((ZDBrowerToolActionType) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.configMainUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clickBackButton() {
        self.backHandler?(.back)
    }
    
    @objc private func tapSelectImage() {
        self.tapRightBadgValueHandler?(.selected)
    }
    
}

//MARK: - public API
extension ZDPhotoPreviewTopView {
    
    func handleBackAction(handler: ((ZDBrowerToolActionType) -> Void)?) {
        self.backHandler = handler
    }
    
    func handleSelectPhotoAction(handler: ((ZDBrowerToolActionType) -> Void)?){
        self.tapRightBadgValueHandler = handler
    }
    
    /// 设置选中的角标
    func setRightBadgValue(_ index: Int? , _ isAnimation: Bool = false) {
        if let value = index {
            self.rightBadgValueLab.isHidden = false
            self.selectImageView.isHidden = true
            self.rightBadgValueLab.text = "\(value)"
            if isAnimation { self.rightBadgValueLab.addScaleBigerAnimation() }
        }else {
            self.rightBadgValueLab.text = nil
            self.rightBadgValueLab.isHidden = true
            self.selectImageView.isHidden = false
        }
    }
    
}

extension ZDPhotoPreviewTopView {
    
    private func configMainUI() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.addSubview(backButton)
        self.addSubview(selectImageView)
        self.addSubview(rightBadgValueLab)
        let vd: [String: UIView] = ["backButton": backButton , "selectImageView": selectImageView , "rightBadgValueLab": rightBadgValueLab]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-18-[backButton]-(>=0)-[selectImageView(22)]-12-|", options: [.alignAllCenterY], metrics: nil, views: vd))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[rightBadgValueLab(22)]-12-|", options: [], metrics: nil, views: vd))
        backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: UIDevice.APPTOPSAFEHEIGHT/2).isActive = true
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        selectImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        rightBadgValueLab.heightAnchor.constraint(equalToConstant: 22).isActive = true
        rightBadgValueLab.centerYAnchor.constraint(equalTo: selectImageView.centerYAnchor, constant: 0).isActive = true
        rightBadgValueLab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSelectImage)))
        selectImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSelectImage)))
    }
    
}
