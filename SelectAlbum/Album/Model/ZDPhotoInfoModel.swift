//
//  ZDPhotoModel.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import Foundation
import Photos

/**
 *  相片模型
 */
struct ZDPhotoInfoModel: Equatable {
    
    private (set) var isSelectedState: Bool = false

    /// 选中的角标,nil,或者小于0未选中
    var selectbadgeValue: Int? = nil {
        didSet{
            self.isSelectedState = !(selectbadgeValue == nil)
        }
    }
    
    var asset: PHAsset
    
    /// 列表界面展示的下标位置
    var row: Int
    
    init (_ asset: PHAsset , _ row: Int) {
        self.asset = asset
        self.row = row
    }
    
    /// 获取原图的大小
    func getOrginImageByte(completeHandler: ((Int64) -> Void)?) {
        ZDPhotoImageManager.getOriginImageByte(self.asset, completeHandler: completeHandler)
    }
    
    static func == (lhs: ZDPhotoInfoModel, rhs: ZDPhotoInfoModel) -> Bool {
        return lhs.asset.localIdentifier == rhs.asset.localIdentifier
    }
}
