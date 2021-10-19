//
//  ViewController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/11.
//

import UIKit


class ViewController: UIViewController {
    
    let lab = YYFPSLabel(frame: CGRect(x: 300, y: 40, width: 60, height: 30))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        let button = UIButton(type: .contactAdd)
        self.view.addSubview(button)
        button.frame = CGRect(x: 100, y: 100, width: 40, height: 40)
        button.addTarget(self, action: #selector(clickSelectPhoto), for: .touchUpInside)
        
        let v = UIView();
        v.backgroundColor = UIColor(hexString: "#FF813B")
        v.bounds = CGRect(x: 0, y: 0, width: 22, height: 22)
        
        let imageView = UIImageView(frame: CGRect(x: 200, y: 200, width: 22, height: 22))
        self.view.addSubview(imageView)
        imageView.image = v.drawCirleImage(20)
        
        UIDevice.APPWINDOW.addSubview(lab)
        
    }
    
    @objc private func clickSelectPhoto() {
        self.presentPhotoList()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            UIDevice.APPWINDOW.bringSubviewToFront(self.lab)
        }
    }

}

