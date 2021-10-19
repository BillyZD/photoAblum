//
//  ZDPhotoAssetImageCell.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit
import Photos

/**
 *  照片列表cell
 */
class ZDPhotoAssetImageCell: UICollectionViewCell {
    
    private var photoImageView: UIImageView = UIImageView()
    
    private var _maskView: ZDPhotoAssetMaskView = ZDPhotoAssetMaskView()
    
    private var imageRequestID: Int32?
    
    private var asset: PHAsset?
    
    private var selectedHandler: (() -> Int?)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configMainUI()
        _maskView.handleTapRightBadgValue { [weak self] in
            self?.clickSelectedPhoto()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func clickSelectedPhoto() {
        let selectIndex = self.selectedHandler?()
        self._maskView.setRightBagdValue(selectIndex)
        if selectIndex != nil {
            self._maskView.startSelectAnimation()
        }
    }
    
}

//MARK: - public API
extension ZDPhotoAssetImageCell {
    
    /// 更新cell
    func updateCell(_ model: ZDPhotoInfoModel) {
        self.asset = model.asset
        let imageRequestID = ZDPhotoImageManager.requestPhotoImageWithAsset(model.asset, CGSize(width: self.frame.size.width * 2, height: self.frame.size.height * 2), complete: { [weak self] _image, isDegraded , iCloudFailed in
            if self?.asset?.localIdentifier == model.asset.localIdentifier {
                self?.photoImageView.image = _image
                if !isDegraded {
                    self?.imageRequestID = nil
                }
            }else {
                if let _imageRequestID = self?.imageRequestID {
                    PHImageManager.default().cancelImageRequest(_imageRequestID)
                }
            }
        }, networkAccessAllowed: false)
        if let _imageRequestID = self.imageRequestID , _imageRequestID != imageRequestID {
            // 取消上一个照片请求
            PHImageManager.default().cancelImageRequest(_imageRequestID)
        }
        self.imageRequestID = imageRequestID
        self._maskView.setRightBagdValue(model.selectbadgeValue)
    }
    
    /// 是否设置蒙层(不允许选中)
    func setShowMaskState(_ isShow: Bool) {
        if isShow {
            self._maskView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        }else {
            self._maskView.backgroundColor = UIColor.white.withAlphaComponent(0)
        }
    }
    
    /// 设置选中的角标
    func setRightBagdValue(_ bagdValue: Int?) {
        self._maskView.setRightBagdValue(bagdValue)
        self.isSelected = !(bagdValue == nil)
    }
    
    func handleSelectedAction(handler: (() -> Int?)?) {
        self.selectedHandler = handler
    }
    
    func localIdentifier() -> String? {
        return self.asset?.localIdentifier
    }
    
}


//MARK: - UI API
extension ZDPhotoAssetImageCell {
    
    private func configMainUI() {
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(photoImageView)
        self.contentView.addSubview(_maskView)
        let vd: [String: UIView] = ["photoImageView": photoImageView , "maskView": _maskView]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[photoImageView]|", options: [], metrics: nil, views: vd))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[maskView]|", options: [], metrics: nil, views: vd))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[photoImageView]|", options: [], metrics: nil, views: vd))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskView]|", options: [], metrics: nil, views: vd))
    }
}



