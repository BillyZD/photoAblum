//
//  UIViewController+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit

extension UIViewController {
    
    /// 显示相册列表界面
    func presentPhotoList() {
        guard (self is ZDPhotoListController) == false else { return }
        let nav = ZDNavigationController(rootViewController: ZDPhotoListController())
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    /// 设置导航栏背景色
    func setNavBarBackgroundColor(_ color: UIColor) {
        guard let navController = self.navigationController else {return}
        if #available(iOS 13.0, *) {
            if let appearance = navController.navigationBar.scrollEdgeAppearance {
                appearance.backgroundColor = color
                navController.navigationBar.standardAppearance = appearance
            }else {
                navController.navigationBar.barTintColor = color
            }
        }else {
            navController.navigationBar.barTintColor = color
        }
    }
}
