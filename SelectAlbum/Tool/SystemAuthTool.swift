//
//  SystemAuthorTool.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import Foundation
import UIKit
import Photos

/// 授权状态
enum AuthorizationStatus {
    
    /// 不确定
    case notDetermined
    
    /// 拒绝访问
    case denied
    
    /// 允许访问
    case authorized
    
    /// 没有权限访问
    case restricted
    
    /// 访问受限，只能访问部分
    case limited
    
    static func getAuthorizationStatus(_ status: PHAuthorizationStatus) -> AuthorizationStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        @unknown default:
            return .denied
        }
    }
}

/**
 *  系统权限工具类
 */
enum ZDSystemAuthType {
   
    /// 相册权限
    case albumAuthType
    
    var noAuthAlertTextDescribe: String{
        switch self{
        case .albumAuthType:
            return "您已拒绝\(UIDevice.APPNAME)访问您的相册使用，请前往系统设置打开权限"
        }
    }
    
}

extension ZDSystemAuthType {
    
    /// 是否有权限访问
    func isAuthorization() -> Bool {
        switch self {
        case .albumAuthType:
            let status = self.getAlbumAuthType()
            return status == .authorized || status == .limited
        }
    }
    
    /// 请求权限弹框
    func requestSystemAuth(completeHandle: ((AuthorizationStatus) -> Void)?) {
        switch self{
        case .albumAuthType:
            func handleComplete(_ status: PHAuthorizationStatus) {
                DispatchQueue.main.async {
                    completeHandle?(AuthorizationStatus.getAuthorizationStatus(status))
                }
            }
            
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    handleComplete(status)
                }
            } else {
                PHPhotoLibrary.requestAuthorization { status in
                    handleComplete(status)
                }
            }
        }
    }
    
    /// 获取访问相册的权限
    func getAlbumAuthType() -> AuthorizationStatus {
        let albumAuth: PHAuthorizationStatus
        if #available(iOS 14, *) {
            albumAuth = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            albumAuth = PHPhotoLibrary.authorizationStatus()
        }
        return AuthorizationStatus.getAuthorizationStatus(albumAuth)
    }
    
    /// 创建没有权限的弹框
    func getNoAuthAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: self.noAuthAlertTextDescribe, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "去设置", style: .default, handler: { _ in
            if let url = URL.init(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        return alert
    }
}
