//
//  ZDPhotoSelectModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/20.
//

import Foundation
import Photos

protocol ZDSelectProtocolDelegate: AnyObject {
    
    /// 允许选择的图片
    var selectMaxCount: Int {get}
    
    func selectPHAssetsComplete(assets: [PHAsset])
    
    func selectPhotosComplete(phtots: [UIImage])
    
}

extension ZDSelectProtocolDelegate {
    
    func selectPHAssetsComplete(assets: [PHAsset]) {}
}
