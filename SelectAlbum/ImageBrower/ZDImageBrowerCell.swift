//
//  ZDImageBrowerCell.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/21.
//

import Foundation


class ZDImageBrowerCell: UICollectionViewCell {
    
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
    
    ///
    private var scrollView: ZDBrowerScrollView = {
        let scroll = ZDBrowerScrollView()
        scroll.isMultipleTouchEnabled = true
        scroll.scrollsToTop = false
        scroll.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            scroll.contentInsetAdjustmentBehavior = .never
        }
        return scroll
    }()
    
    private var singletapHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configMainUI()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        self.addGestureRecognizer(singleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = CGRect(x: 10, y: 0, width: self.frame.size.width - 20, height: self.frame.size.height)
        self.resizeSubViews()
    }
    
    func updateCell(_ image: UIImage) {
        self.imageView.image = image
        self.resizeSubViews()
    }
    
    /// 单点回调
    func handleSingleTap(handler: (() -> Void)?) {
        self.singletapHandler = handler
    }
    
    func getAnimationView() -> UIView {
        return self.imageView
    }
    
}

extension ZDImageBrowerCell {
    
    /// 处理单击
    @objc private func singleTap() {
        self.singletapHandler?()
    }
    
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
    
    
}


extension ZDImageBrowerCell {
    
    private func configMainUI() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
    }
    
}


private class ZDBrowerScrollView: UIScrollView {
    
    // 避免和预览界面下滑动手势冲突
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = pan.translation(in: pan.view)
            // 顶部向下滑动，禁止响应
            if self.contentOffset.y == 0 ,  translation.y > 0 {
                return false
            }
        }
        return true
    }
    
}
