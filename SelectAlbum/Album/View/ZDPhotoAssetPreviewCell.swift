//
//  ZDPhotoAssetPreviewCell.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/14.
//

import UIKit
import Photos

/**
 *  相册图片大图预览cell
 */
class ZDPhotoAssetPreviewCell: UICollectionViewCell {
    
    private var imageRequestID: PHImageRequestID?
    
    private var asset: PHAsset?
    
    private var imageView: UIImageView = UIImageView()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            activity.style = .large
        } else {
            activity.style = .whiteLarge
        }
        activity.hidesWhenStopped = true
        return activity
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configMainUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ZDPhotoAssetPreviewCell {
    
    func updateCell(_ model: ZDPhotoInfoModel) {
        
        if let _imageRequestID = self.imageRequestID , asset != nil {
            PHImageManager.default().cancelImageRequest(_imageRequestID)
        }
        self.asset = model.asset
        self.imageRequestID = ZDPhotoImageManager.requestPreviewImage(model.asset) { image, isDegraded, isCloudFailed in
            if image == nil , isCloudFailed {
                "iCound同步照片失败".showToWindow()
            }
            if self.asset?.localIdentifier != model.asset.localIdentifier { return }
            self.imageView.image = image
            if !isDegraded {
                self.imageRequestID = nil
            }
        } progressHandler: { progerss, err in
            if let errText = err?.localizedDescription {
                errText.showToWindow()
                self.activityIndicator.stopAnimating()
            }
            if progerss >= 1 {
                self.activityIndicator.stopAnimating()
            }else {
                self.activityIndicator.startAnimating()
            }
        }

    }
    
}

extension ZDPhotoAssetPreviewCell {
    
    private func configMainUI() {
        backgroundColor = UIColor.black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        contentView.addSubview( imageView)
        let vd: [String: UIView] = ["imageView": imageView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-10-[imageView]-10-|", options: [], metrics: nil, views: vd))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: vd))
        contentView.addSubview(self.activityIndicator)
        activityIndicator.center = self.center
    }
    
}
