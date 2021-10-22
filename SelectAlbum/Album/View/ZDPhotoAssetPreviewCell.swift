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
    
    /// 设置图片的父试图View
    private let imageContainerView: UIView = {
        let container = UIView()
        container.clipsToBounds = true
        container.contentMode = .scaleAspectFill
        return container
    }()
    
    /// 显示图片
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    

    /// 放大缩小
    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.bouncesZoom = true
        scroll.maximumZoomScale = 2.5
        scroll.minimumZoomScale = 1.0
        scroll.isMultipleTouchEnabled = true
        scroll.scrollsToTop = false
        scroll.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            scroll.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        return scroll
    }()
    
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
    
    private var singletapHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configMainUI()
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(tap:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        self.addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = CGRect(x: 10, y: 0, width: self.frame.size.width - 20, height: self.frame.size.height)
        self.recoverSubviews()
    }
    
}

//MARK: - public API
extension ZDPhotoAssetPreviewCell {
    
    /// 回复初始化状态
    func recoverSubviews() {
        self.scrollView.setZoomScale(1.0, animated: false)
        self.resizeSubViews()
    }
    
    /// 单点回调
    func handleSingleTap(handler: (() -> Void)?) {
        self.singletapHandler = handler
    }
    
    /// 更新cell
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
            self.resizeSubViews()
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

//MARK: - logic API
extension ZDPhotoAssetPreviewCell {
    
    /// 设置子试图frame
    private func resizeSubViews() {
        imageContainerView.frame.origin = CGPoint.zero
        imageContainerView.frame.size.width = scrollView.frame.width
        if let image = self.imageView.image {
            if image.size.height / image.size.width > scrollView.frame.size.height / scrollView.frame.size.width {
                // 长图
                imageContainerView.frame.size.height = image.size.height * (scrollView.frame.size.width/image.size.width)
            }else {
                var height: CGFloat = 0
                if image.size.width <= 0 {
                    height = self.scrollView.frame.width
                }else {
                    height = scrollView.frame.size.width * (image.size.height/image.size.width)
                }
                imageContainerView.frame.size.height = height
                imageContainerView.center.y = self.frame.size.height/2
            }
            // 消除误差
            if self.imageContainerView.frame.size.height > self.frame.size.height , self.imageContainerView.frame.size.height - self.frame.size.height <= 1 {
                self.imageContainerView.frame.size.height = self.frame.size.height
            }
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: max(self.scrollView.frame.size.height, self.imageContainerView.frame.size.height))
            self.scrollView.scrollRectToVisible(self.bounds, animated: false)
            self.scrollView.alwaysBounceVertical = imageContainerView.frame.size.height > self.frame.size.height
            self.imageView.frame = imageContainerView.bounds
        }
    }
    
    /// 设置中心位置
    private func refreshImageContainerViewCenter() {
        // 缩小时，设置中心位置
        let offsetX = (self.scrollView.frame.size.width > self.scrollView.contentSize.width) ? ((self.scrollView.frame.size.width - self.scrollView.contentSize.width) * 0.5) : 0.0
        let offsetY = (self.scrollView.frame.size.height > self.scrollView.contentSize.height) ? ((self.scrollView.frame.size.height - self.scrollView.contentSize.height) * 0.5) : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    /// 处理双击
    @objc private func doubleTap(tap: UITapGestureRecognizer) {
        if self.scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.setZoomScale(1.0, animated: true)
        }else {
            let touchPoint = tap.location(in: self.imageView)
            let xsize = self.frame.size.width / scrollView.maximumZoomScale
            let ysize = self.frame.size.height / scrollView.maximumZoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize), animated: true)
        }
    }
    
    /// 处理单击
    @objc private func singleTap() {
        self.singletapHandler?()
    }
}


extension ZDPhotoAssetPreviewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.refreshImageContainerViewCenter()
    }
    
}

extension ZDPhotoAssetPreviewCell {
    
    private func configMainUI() {
        scrollView.backgroundColor = UIColor.black
        contentView.backgroundColor = UIColor.black
        scrollView.delegate = self
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        contentView.addSubview(self.activityIndicator)
        activityIndicator.center = self.center
    }
    
}
