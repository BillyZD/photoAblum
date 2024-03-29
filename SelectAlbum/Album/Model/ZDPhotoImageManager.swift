//
//  ZDPhotoImageManager.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit
import Photos

/**
 *  请求图片
 */
struct ZDPhotoImageManager {
    
    /// @2x
    static var ZDScreenScale: CGFloat{
        if UIDevice.APPSCREENWIDTH > 700 {
            return 1.5
        }
        return 2.0
    }
    
    /// 预览图片最大宽度
    static var previewMaxWidth: CGFloat = 600 {
        didSet{
            if previewMaxWidth <= 0 {
                previewMaxWidth = 600
            }
        }
    }
    
    /// 缩略图大小
    static var thumbnailSize: CGSize = CGSize(width: 160, height: 160)
    
    /// 是否显示GIF动图
    static var isAllowGIFPhoto: Bool = true
    
    /// 是否返回原图data
    static var isAllowSelectOrigin: Bool = true
}

// MARK: - public API
extension ZDPhotoImageManager {
    
    /// 获取选取的图片
    static func getSelectPhotoImage(_ asset: PHAsset , complete:((UIImage) -> Void)? , progressHandler:((Double) -> Void)?, failed: ((String) -> Void)?) {
        self.requestPreviewImage(asset) { image, isDegraded, isCloudFailed in
            if !isDegraded , let _image = image {
                complete?(_image)
            }
            if isCloudFailed , image == nil { failed?("iClound下载失败")}
        } progressHandler: { progress, err in
            if err != nil {
                failed?(err!.localizedDescription)
            }
            progressHandler?(progress)
        }
    }
    
    /// 获取预览图片
    @discardableResult
    static func requestPreviewImage(_ asset: PHAsset ,
                                    complete: ((_ image: UIImage? , _ isDegraded: Bool , _ isCloudFailed: Bool) -> Void)?,
                                    progressHandler:((Double , Error?) -> Void)? = nil ,
                                    networkAccessAllowed: Bool = true) -> PHImageRequestID{
        var photoWidth = UIDevice.APPSCREENWIDTH
        if photoWidth > previewMaxWidth {
            photoWidth = previewMaxWidth
        }
        var pixelWidth = photoWidth * ZDScreenScale
        let aspectRatio: CGFloat = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        // 超宽图片
        if aspectRatio > 1.8 {
            pixelWidth = pixelWidth * aspectRatio
        }
        // 超高图片
        if aspectRatio < 0.2 {
            pixelWidth = pixelWidth * 0.5
        }
        let pixelHeight = pixelWidth/aspectRatio
        return self.requestPhotoImageWithAsset(asset, CGSize(width: pixelWidth, height: pixelHeight), complete: complete, progressHandler: progressHandler, networkAccessAllowed: networkAccessAllowed)
        
    }
    
    /// 获取原图大小
    static func getOriginImageByte(_ asset: PHAsset , completeHandler: ((Int64) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            self.getOriginImageData(asset, resultHandler: { data, dataUTI, orientation, info in
                DispatchQueue.main.async {
                    if let _data = data {
                        completeHandler?(Int64(_data.count))
                    }else {
                        completeHandler?(0)
                    }
                }
            }, progressHandler: nil)
        }
    }
    
    /// 获取制定大小的图片
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - size: 指定大小
    ///   - complete: 请求成功的回调，回调用多次
    ///   - progressHandler: 从iCloud下载的进度，如果需要下载
    ///   - networkAccessAllowed: 是否允许从iCloud下载
    /// - Returns: PHImageRequestID
    @discardableResult
    static func requestPhotoImageWithAsset(_ asset: PHAsset ,
                                           _ size: CGSize ,
                                           complete: ((_ image: UIImage? , _ isDegraded: Bool , _ iCloudFailed: Bool) -> Void)?,
                                           progressHandler:((Double , Error?) -> Void)? = nil ,
                                           networkAccessAllowed: Bool = true) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        return PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { result, info in
            let canelled = info?[PHImageCancelledKey] as? Bool ?? false
            let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? true
            let iCloudFailed = self.isICloudSyncError(info?[PHImageErrorKey] as? NSError)
            if !canelled , result != nil {
                complete?(result , isDegraded , iCloudFailed)
            }
            // 判断是否需要从iCloud下载
            if networkAccessAllowed , result == nil , info?[PHImageResultIsInCloudKey] != nil {
                self.getOriginImageData(asset) { data, dataUTI, orientation, info in
                    let isCloudFailed = self.isICloudSyncError(info?[PHImageErrorKey]  as? NSError)
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        complete?(image?.scaleImage(newsize: size) , false , isCloudFailed)
                    }else {
                        complete?(result , false , isCloudFailed)
                    }
                } progressHandler: { progress, err, stop, info in
                    DispatchQueue.main.async {
                        progressHandler?(progress , err)
                    }
                }
            }
        }
    }
    
    /// 获取原图data
    static func getOriginImageData(_ asset: PHAsset ,resultHandler: @escaping (Data?, String?, CGImagePropertyOrientation, [AnyHashable : Any]?) -> Void , progressHandler: ((Double, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void)?) {
        let downOption = PHImageRequestOptions()
        downOption.resizeMode = .fast
        downOption.deliveryMode = .fastFormat
        downOption.isNetworkAccessAllowed = true
        if  let fileName = asset.value(forKey: "filename") as? String , fileName.hasSuffix("GIF"){
            downOption.version = .original
        }
        downOption.progressHandler = progressHandler
        if #available(iOS 13, *) {
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: downOption, resultHandler: resultHandler)
        } else {
            // Fallback on earlier versions
            PHImageManager.default().requestImageData(for: asset, options: downOption) { data, dataUTI, orientation, info in
                let _orientation: CGImagePropertyOrientation
                switch orientation {
                case .down:
                    _orientation = .down
                case .up:
                    _orientation = .up
                case .left:
                    _orientation = .left
                case .right:
                    _orientation = .right
                case .upMirrored:
                    _orientation = .upMirrored
                case .downMirrored:
                    _orientation = .downMirrored
                case .leftMirrored:
                    _orientation = .leftMirrored
                case .rightMirrored:
                    _orientation = .rightMirrored
                @unknown default:
                    _orientation = .down
                }
                resultHandler(data , dataUTI , _orientation , info)
            }
        }
    }
}

extension ZDPhotoImageManager {
    
    private static func isICloudSyncError(_ err: NSError?) -> Bool {
        if let _domain = err?.domain{
            return _domain == "CKErrorDomain" || _domain == "CloudPhotoLibraryErrorDomain"
        }
        return false
    }
    
}
