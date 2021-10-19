//
//  ZDAlbumManager.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import Foundation
import Photos
import UIKit

/**
 *  相册管理对象
 */
class ZDPhotoAlbumManager: NSObject {
    
    /// 相册模型
    struct ZDAlbumModel: Equatable {
        
        var albumName: String
        
        var assetArr: [ZDPhotoInfoModel]
        
        var selectCount: Int = 0
        
        var coverSize: CGSize = CGSize(width: 100, height: 100)
        
        init(collection: PHAssetCollection) {
            let photosOptions = PHFetchOptions()
            photosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            let result = PHAsset.fetchAssets(in: collection, options: photosOptions)
            self.albumName = collection.localizedTitle ?? "照片"
            if result.count > 0 {
                var tempArr: [ZDPhotoInfoModel] = []
                for i in 0 ..< result.count {
                    tempArr.append(ZDPhotoInfoModel(result[i], i))
                }
                self.assetArr = tempArr
            }else {
                self.assetArr = []
            }
        }
        
        static func == (lhs: ZDAlbumModel, rhs: ZDAlbumModel) -> Bool {
            if lhs.assetArr == rhs.assetArr , lhs.albumName == rhs.albumName {
                return true
            }
            return false
        }
        
        func getCoverImage(completion: ((UIImage?) -> Void)?) {
            if let potoModel = assetArr.last {
                ZDPhotoImageManager.requestPhotoImageWithAsset(potoModel.asset, self.coverSize) { image, isDegraded, iCloudFailed in
                    completion?(image)
                }
            }else {
                completion?(nil)
            }
        }
    }
    
    static let manager: ZDPhotoAlbumManager = ZDPhotoAlbumManager()
    
    /// 是否使用缓存的第一个相册
    var isUsedCachedFirstAlbum: Bool = true
    
    private var firstAlbumModel: ZDAlbumModel?
    
    private override init() {}
    
    override func copy() -> Any {
        return ZDPhotoAlbumManager.manager
    }
    
    override func mutableCopy() -> Any {
        return ZDPhotoAlbumManager.manager
    }
}

extension ZDPhotoAlbumManager {
    
    /// 获取第一个需要展示的相册
    static func getFirstCameraAlbum(completeHandle: ((ZDAlbumModel?) -> Void)?) {
        if let model = self.manager.firstAlbumModel , self.manager.isUsedCachedFirstAlbum {
            completeHandle?(model)
        }else {
            DispatchQueue.global(qos: .background).async {
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
                if smartAlbums.count == 0 {
                    DispatchQueue.main.async {
                        completeHandle?(nil)
                    }
                }else {
                    for i in 0 ..< smartAlbums.count {
                        if smartAlbums[i].assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumUserLibrary {
                            self.manager.isUsedCachedFirstAlbum = true
                            self.manager.firstAlbumModel = ZDAlbumModel(collection: smartAlbums[i])
                            DispatchQueue.main.async {
                                completeHandle?(self.manager.firstAlbumModel)
                            }
                            return
                        }
                    }
                }
            }
        }
    }
    
    /// 获取所有相册
    static func getAllCamerAlbum(completeHandle: (([ZDAlbumModel]) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            if smartAlbums.count == 0 {
                DispatchQueue.main.async {
                    completeHandle?([])
                }
            }else {
                var tempArr: [ZDAlbumModel] = []
                func filterCollection(_ collection: PHAssetCollection) {
                    if collection.estimatedAssetCount > 0{
                        if collection.assetCollectionSubtype.rawValue == 1000000201 {
                            ZDLog("过滤最近删除相册")
                        }else {
                            if collection.assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumUserLibrary {
                                tempArr.insert(ZDAlbumModel(collection: collection), at: 0)
                            }else {
                                tempArr.append(ZDAlbumModel(collection: collection))
                            }
                        }
                    }
                }
                
                for i in 0 ..< smartAlbums.count {
                    filterCollection(smartAlbums[i])
                }
                
                // 加载用户自定义相册
                let topLevelUserCollections: PHFetchResult<PHCollection> = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
                if topLevelUserCollections.count > 0 {
                    for i in 0 ..< topLevelUserCollections.count - 1 {
                        if let collection = topLevelUserCollections[i] as? PHAssetCollection {
                            filterCollection(collection)
                        }
                    }
                }
                tempArr = tempArr.filter({$0.assetArr.count > 0})
                DispatchQueue.main.async {
                    completeHandle?(tempArr)
                }
            }
        }
    }
    
}
