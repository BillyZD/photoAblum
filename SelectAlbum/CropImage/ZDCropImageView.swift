//
//  ZDCropImageView.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/29.
//

import Foundation
import UIKit

/**
 *  裁剪View
 */
class ZDCropImageView: UIView {
    
    private let cropRectView: ZDCropRectView = ZDCropRectView(frame: UIScreen.main.bounds)
    
    private var completeHandler: ((UIImage?) -> Void)?
    
    private var isAutomSetZoom: Bool = false
    
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
        scroll.maximumZoomScale = ZDCropImageManager.manager.cropMaxZoomSale
        scroll.minimumZoomScale = ZDCropImageManager.manager.cropMinZoomSale
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
    
    
    convenience init(cropImage: UIImage, completeHandler: ((UIImage?) -> Void)?) {
        self.init()
        self.setImage(image: cropImage)
        self.completeHandler = completeHandler
        self.setViewBlock()
    }
    
    convenience init( completeHandler: ((UIImage?) -> Void)?) {
        self.init()
        self.completeHandler = completeHandler
       
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        configMainUI()
        self.setViewBlock()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        self.cropRectView.frame = self.bounds
        self.resizeSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCropImage(cropImage: UIImage) {
    
        self.setImage(image: cropImage)
       
    }
    
    func cropComplete(completeHandler: ((UIImage?) -> Void)?) {
        self.completeHandler = completeHandler
    }
}

extension ZDCropImageView {
    
    private func setViewBlock() {
      
        cropRectView.completeCropHandler = { [weak self] rect in
            if let _rect = rect {
                self?.getCropImage(_rect)
            }else {
                // 取消
                self?.completeHandler?(nil)
                self?.removeFromSuperview()
            }
        }
        
        cropRectView.cropRectChangeHandler = { [weak self] in
            guard let `self` = self else {return}
            if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
                if self.scrollView.contentOffset == .zero{
                    self.resizeSubViews()
                   
                }else {
                    UIView.animate(withDuration: 0.25) {
                        self.resizeSubViews()
                    }
                }
            }else {
                UIView.animate(withDuration: 0.25) {
                    self.scrollView.zoomScale = self.scrollView.minimumZoomScale
                }completion: { _ in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        if self.scrollView.contentOffset == .zero{
                            self.resizeSubViews()
                        }else {
                            UIView.animate(withDuration: 0.5) {
                                self.resizeSubViews()
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
    private func setImage(image: UIImage?) {
        self.imageView.image = image
        self.resizeSubViews()
    }
    
    private func handleImageFullCropRect() {
        //  判断照片是否能充满裁剪框
        guard self.imageView.frame.height > 0 else { return }
        let scale = max(self.cropRectView.cropRect.width/self.imageView.frame.width, self.cropRectView.cropRect.height/self.imageView.frame.height)
        if  self.scrollView.minimumZoomScale < scale , scale > 1 {
            // 将照片充满裁剪框
            self.scrollView.minimumZoomScale = scale
            self.scrollView.maximumZoomScale = scale * 2
            self.isAutomSetZoom = true
            self.scrollView.setZoomScale(scale, animated: true)
        }
    }
    
    /**
     *  无论怎么移动，imageView的frame始终是不变的
     *  imageContainerView的frame是会发生变化 width和height * scrollView.zoomScale
     */
    private func getCropImage(_ rect: CGRect) {
        let scale = self.imageView.image!.size.width/self.imageView.frame.size.width
        debugPrint(self.imageView.frame, self.imageView.image!.size)
        let convertRect = self.convert(rect, to: self.scrollView)
        let newCropRect = self.scrollView.convert(convertRect, to: self.imageContainerView)
        let cropRect = CGRect(x: newCropRect.origin.x * scale, y: newCropRect.origin.y * scale, width: newCropRect.width * scale, height: newCropRect.height * scale)
        if let cgImage = self.imageView.image?.cgImage , let cropCgImage = cgImage.cropping(to: cropRect) {
            completeHandler?(UIImage(cgImage: cropCgImage))
        }

        self.removeFromSuperview()
        
    }
    
    /// 设置scroller的contsize和contentInset,用来保证图片的移动在裁剪框内
    private func refreshScollerContentsize() {
        if self.scrollView.frame.size.width > 0 {
            let cropRect = self.cropRectView.cropRect
            // 重新设置contentsize
            let widthAdd = self.scrollView.frame.size.width - cropRect.maxX
            let heightAdd = (min(self.imageContainerView.frame.height, self.frame.height) - cropRect.height)/2
            let newWidth = self.scrollView.contentSize.width + widthAdd
            let newHight = max(self.scrollView.contentSize.height, self.frame.height) + heightAdd
            self.scrollView.contentSize = CGSize(width: newWidth, height: newHight)
            // 新增滑动区域，让照片每一部分都能滑入裁剪框
            if widthAdd > 0 || heightAdd > 0 {
//                let cropCenterY = cropRect.origin.y + cropRect.height/2
                let offsetY: CGFloat = 0 //self.center.y - cropCenterY
                
                self.scrollView.contentInset = UIEdgeInsets(top: heightAdd - offsetY , left: cropRect.origin.x, bottom: offsetY, right: 0)
            }else {
                self.scrollView.contentInset = UIEdgeInsets.zero
            }
        }
    }
}

extension ZDCropImageView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if self.isAutomSetZoom {
            scrollView.contentInset = .zero
            self.isAutomSetZoom = false
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.refreshImageContainerViewCenter()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.refreshScollerContentsize()
    }
    
}


extension ZDCropImageView {
    
    private func configMainUI() {
       
        scrollView.delegate = self
        self.addSubview(scrollView)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        self.addSubview(cropRectView)
    }
    
    /// 设置子试图frame
    private func resizeSubViews() {
        imageContainerView.frame.origin = CGPoint.zero
        imageContainerView.frame.size.width = scrollView.frame.width
        if let image = self.imageView.image , scrollView.frame.height > 0 {
            if image.size.height / image.size.width > scrollView.frame.size.height / scrollView.frame.size.width {
                // 超长图
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
            self.scrollView.contentSize = CGSize(width: max(self.scrollView.frame.size.width, self.imageContainerView.frame.size.width), height: max(self.scrollView.frame.size.height, self.imageContainerView.frame.size.height))
            self.scrollView.scrollRectToVisible(self.bounds, animated: false)
            self.scrollView.alwaysBounceVertical = imageContainerView.frame.size.height > self.frame.size.height
            self.imageView.frame = imageContainerView.bounds
            self.refreshScollerContentsize()
            self.handleImageFullCropRect()
           
        }
    }
    
    /// 设置中心位置
    private func refreshImageContainerViewCenter() {
        let offsetX = (self.scrollView.frame.size.width > self.scrollView.contentSize.width) ? ((self.scrollView.frame.size.width - self.scrollView.contentSize.width ) * 0.5) : 0.0
        let offsetY = (self.scrollView.frame.size.height > self.scrollView.contentSize.height) ? ((self.scrollView.frame.size.height - self.scrollView.contentSize.height) * 0.5) : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX , y: scrollView.contentSize.height * 0.5 + offsetY)
   
        
    }
}
