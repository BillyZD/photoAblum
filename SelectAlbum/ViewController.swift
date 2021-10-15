//
//  ViewController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/11.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        let button = UIButton(type: .contactAdd)
        self.view.addSubview(button)
        button.frame = CGRect(x: 100, y: 100, width: 40, height: 40)
        button.addTarget(self, action: #selector(clickSelectPhoto), for: .touchUpInside)
    
    }
    
    @objc private func clickSelectPhoto() {
        self.presentPhotoList()
    }

}

