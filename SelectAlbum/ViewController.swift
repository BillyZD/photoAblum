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

    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.APPWINDOW.addSubview(lab)
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        let button = UIButton(type: .custom)
        self.view.addSubview(button)
        button.frame = CGRect(x: 100, y: 100, width: 40, height: 40)
        button.addTarget(self, action: #selector(clickSelectPhoto), for: .touchUpInside)
        
       
        
    }
    
    @objc private func clickSelectPhoto() {
        self.presentPhotoList(self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            UIDevice.APPWINDOW.bringSubviewToFront(self.lab)
        }
    }

}

extension ViewController: ZDSelectProtocolDelegate {
    
    var selectMaxCount: Int {
       return 9
    }
    
   
    func selectPhotosComplete(phtots: [UIImage]) {
        ZDLog(phtots)
        phtots.forEach { image in
            if let data = image.jpegData(compressionQuality: 1.0) {
                debugPrint(Double(data.count).getByteCountText())
            }
        }
    }
}
