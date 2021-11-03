//
//  ZDCropToolView.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/11/1.
//

import Foundation

enum ZDCropToolActionType: Int {
    
    case cancle = 1, complete , scale1 , scale16, scale4
    
}

class ZDCropToolView: UIView {
    
    private var completeHandler: ((ZDCropToolActionType) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configMainUI()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - logic API
extension ZDCropToolView {
    

    func completeActionHandler(handler: ((ZDCropToolActionType) -> Void)?) {
        self.completeHandler = handler
    }
    
    @objc private func clickButtonAction(button: UIButton) {
        if let type = ZDCropToolActionType(rawValue: button.tag) {
            completeHandler?(type)
        }
    }
    
}

extension ZDCropToolView {
    
    private func configMainUI() {
        let cancleButton = UIButton(type: .custom) ; cancleButton.translatesAutoresizingMaskIntoConstraints = false
        cancleButton.setTitle("取消", for: .normal) ; cancleButton.setTitleColor(.white, for: .normal)
        cancleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancleButton.tag = ZDCropToolActionType.cancle.rawValue
        self.addSubview(cancleButton)
        let sureButton = UIButton(type: .custom) ; sureButton.translatesAutoresizingMaskIntoConstraints = false
        sureButton.setTitle("确定", for: .normal) ; sureButton.setTitleColor(.white, for: .normal)
        sureButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sureButton.tag = ZDCropToolActionType.complete.rawValue
        self.addSubview(sureButton)
        let firstButton = UIButton(type: .custom) ; firstButton.translatesAutoresizingMaskIntoConstraints = false
        firstButton.setTitle("1:1", for: .normal) ; firstButton.setTitleColor(.white, for: .normal)
        firstButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        firstButton.tag = ZDCropToolActionType.scale1.rawValue
        self.addSubview(firstButton)
        let secondButton = UIButton(type: .custom) ; secondButton.translatesAutoresizingMaskIntoConstraints = false
        secondButton.setTitle("16:9", for: .normal) ; secondButton.translatesAutoresizingMaskIntoConstraints = false
        secondButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        secondButton.tag = ZDCropToolActionType.scale16.rawValue
        self.addSubview(secondButton)
        let thirdButton = UIButton(type: .custom) ; thirdButton.translatesAutoresizingMaskIntoConstraints = false
        thirdButton.setTitle("4:3", for: .normal) ; thirdButton.setTitleColor(.white, for: .normal)
        thirdButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        thirdButton.tag = ZDCropToolActionType.scale4.rawValue
        self.addSubview(thirdButton)
        let vd: [String: UIView] = ["cancleButton": cancleButton , "firstButton": firstButton , "secondButton": secondButton , "thirdButton": thirdButton , "sureButton": sureButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[cancleButton]-10-[firstButton(==cancleButton)]-10-[secondButton(==cancleButton)]-10-[thirdButton(==cancleButton)]-10-[sureButton(==cancleButton)]-16-|", options: [.alignAllTop , .alignAllBottom], metrics: nil, views: vd))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[cancleButton(30)]", options: [], metrics: nil, views: vd))
        if #available(iOS 11.0, *) {
            cancleButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        } else {
            // Fallback on earlier versions
            cancleButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        }
        cancleButton.addTarget(self, action: #selector(clickButtonAction(button:)), for: .touchUpInside)
        sureButton.addTarget(self, action: #selector(clickButtonAction(button:)), for: .touchUpInside)
        firstButton.addTarget(self, action: #selector(clickButtonAction(button:)), for: .touchUpInside)
        secondButton.addTarget(self, action: #selector(clickButtonAction(button:)), for: .touchUpInside)
        thirdButton.addTarget(self, action: #selector(clickButtonAction(button:)), for: .touchUpInside)
    }
    
}
