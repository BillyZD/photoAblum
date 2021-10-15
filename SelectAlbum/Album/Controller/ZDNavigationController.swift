//
//  ZDNavController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit

class ZDNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = false
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
        //    appearance.shadowColor = UIColor.clear
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        } else {
            self.navigationBar.tintColor = UIColor.white
            // Fallback on earlier versions
        }
    }
    
    
    
}
