//
//  ZDPhotoSelectModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/20.
//

import Foundation
import Photos

protocol ZDSelectPhotoDelegate: AnyObject {
    
    /// 允许选择的图片
    var selectMaxCount: Int {get}
    
    func selectPHAssetsComplete(assets: [PHAsset])
    
    func selectPhotosImageComplete(photos: [UIImage])
    
}

extension ZDSelectPhotoDelegate {
    
    func selectPHAssetsComplete(assets: [PHAsset]) {}

}

