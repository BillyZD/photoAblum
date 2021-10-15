//
//  UIDevice+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit

extension UIDevice {
    
    /// 工程名称
    static var APPNAME: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }
    
    /// 屏幕宽度
    static var APPSCREENWIDTH: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    /// 屏幕高度
    static var APPSCREENHEIGHT: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    /// 展示window
    static var APPWINDOW: UIWindow {
        if let app = UIApplication.shared.delegate as? AppDelegate {
            return app.window ?? UIWindow()
        }
        return UIWindow()
    }
    
    /// 底部安全区域高度
    static var APPBOTTOMSAFEHEIGHT: CGFloat {
        if #available(iOS 11.0, *) {
            return (UIApplication.shared.delegate as? AppDelegate)?.window?.safeAreaInsets.bottom ?? 0
        }
        return 0
    }
    
    /// 顶部安全区域高度
    static var APPTOPSAFEHEIGHT: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
}
