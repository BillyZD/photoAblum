//
//  ViewController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/11.
//

import UIKit
import Photos


class ViewController: UIViewController {
    
    let lab = YYFPSLabel(frame: CGRect(x: 300, y: 40, width: 60, height: 30))
    
    private let presentAnimation = ZDPresentAnimationModel()
    
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.APPWINDOW.addSubview(lab)
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        let button = UIButton(type: .custom)
        button.setTitle("选择照片", for: .normal)
        button.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        self.view.addSubview(button)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 40)
        button.addTarget(self, action: #selector(clickSelectPhoto), for: .touchUpInside)
        
        imageView.frame = CGRect(x: 0, y: 200, width: 200, height: 200)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.view.addSubview(imageView)
        if let path = Bundle.main.path(forResource: "test", ofType: "jpg") {
            imageView.image = UIImage(contentsOfFile: path)
        }
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImageView)))
        
    }
    
    @objc private func clickSelectPhoto() {
        self.presentPhotoList(self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            UIDevice.APPWINDOW.bringSubviewToFront(self.lab)
        }
    }
    
    
    @objc private func tapImageView() {
        
    }
}


extension ViewController: ZDSelectProtocolDelegate {
    
    var selectMaxCount: Int {
       return 9
    }
    
    func selectPhotosComplete(phtots: [UIImage]) {
        phtots.forEach { image in
            if let data = image.jpegData(compressionQuality: 1.0) {
                debugPrint(Double(data.count).getByteCountText())
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let convertRect = self.view.convert(self.imageView.frame, to: UIDevice.APPWINDOW)
            let browerController = ZDImageBrowerController(phtots, startIndex: 0) { _ in
                return convertRect
            }
            browerController.showImageBrower(self, startRect: convertRect)
        }
    }
}


