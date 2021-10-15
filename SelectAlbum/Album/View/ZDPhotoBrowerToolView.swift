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

class ZDPhotoBrowerBottomView: UIView {
    
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
        button.backgroundColor = UIColor(hexString: "#FF813B")
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
extension ZDPhotoBrowerBottomView {
    
    /// 设置原图大小
    func setOriginByte(_ byte: Int64) {
        self.originByteLabel.text = "原图(\(Double(byte).getByteCountText()))"
    }
    
    /// 设置完成按钮是否可用
    func isAbleComplete(_ isAble: Bool) {
        self.completeButton.isUserInteractionEnabled = isAble
        self.completeButton.backgroundColor =  isAble ? UIColor(hexString: "#FF813B") : UIColor(hexString: "#FF813B")
    }
    
    func handleCompleteAction(handler: ((ZDBrowerToolActionType) -> Void)?) {
        self.completeHandler = handler
    }
}

extension ZDPhotoBrowerBottomView {
    
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


class ZDPhotoBrowerTopView: UIView {
    
    private let backButton: UIButton = {
        let button = UIButton() ; button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage("album_back_white".toImage(), for: .normal)
        return button
    }()
    
    private var backHandler: ((ZDBrowerToolActionType) -> Void)?
    
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
    
}

//MARK: - public API
extension ZDPhotoBrowerTopView {
    
    func handleBackAction(handler: ((ZDBrowerToolActionType) -> Void)?) {
        self.backHandler = handler
    }
    
}

extension ZDPhotoBrowerTopView {
    
    private func configMainUI() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.addSubview(backButton)
        let vd: [String: UIView] = ["backButton": backButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-18-[backButton]", options: [], metrics: nil, views: vd))
        backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: UIDevice.APPTOPSAFEHEIGHT/2).isActive = true
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
    }
    
}
