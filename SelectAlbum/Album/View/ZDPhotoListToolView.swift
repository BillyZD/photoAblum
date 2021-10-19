//
//  ZDPhotoListToolView.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/18.
//

import UIKit

/**
 *  照片列表，底部工具栏
 */
class ZDPhotoListBottomView: UIView {
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor(hexString: "#999999")
        button.layer.cornerRadius = 14; button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let previewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("预览", for: .normal)
        button.setTitleColor(UIColor(hexString: "#999999"), for: .normal)
        button.setTitleColor(UIColor(hexString: "#333333"), for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private var previewHandler: (() -> Void)?
    
    private var completeHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.white
        self.configMainUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - public API
extension ZDPhotoListBottomView {
    
    func setIsEnabledState(_ isEnabled: Bool) {
        self.completeButton.isUserInteractionEnabled = isEnabled
        self.previewButton.isUserInteractionEnabled = isEnabled
        self.previewButton.isSelected = isEnabled
        self.completeButton.backgroundColor = isEnabled ? UIColor(hexString: "#FF813B") : UIColor(hexString: "#999999")
    }
    
    
    /// 事件回调
    /// - Parameters:
    ///   - previewHandler: 预览回调
    ///   - completeHandler: 完成回调
    func handleCompleteAction(previewHandler: (() -> Void)? , completeHandler: (() -> Void)?) {
        self.previewHandler = previewHandler
        self.completeHandler = completeHandler
    }
    
}

extension ZDPhotoListBottomView {
    
    @objc private func clickPreviewButton() {
        self.previewHandler?()
    }
    
    @objc private func clickCompleteButton() {
        self.completeHandler?()
    }
    
}

extension ZDPhotoListBottomView {
    
    private func configMainUI() {
        self.addSubview(previewButton)
        self.addSubview(completeButton)
        let vd: [String: UIView] = ["previewButton": previewButton , "completeButton": completeButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-12-[previewButton(45)]-(>=0)-[completeButton(60)]-|", options: [.alignAllTop , .alignAllBottom], metrics: nil, views: vd))
        completeButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        completeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -UIDevice.APPBOTTOMSAFEHEIGHT/2).isActive = true
        completeButton.addTarget(self, action: #selector(clickCompleteButton), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(clickPreviewButton), for: .touchUpInside)
    }
}
