//
//  ZDPhotoPreviewController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/13.
//

import UIKit

/// 预览界面事件回调
protocol SHPhotoPreviewDelegate: AnyObject {
    
    /// 开始选择照片
    /// - Parameters:
    ///   - row: 数据源中，原列表中的下标'ZDPhotoInfoModel中的row'
    /// - Returns: 返回选择照片结果
    func startsSelectPhoto(_ row: Int) -> ZDSelectPhotoResult
    
    
    /**
     *  裁剪/还原完成的回调
     *  裁剪成功，返回裁剪后的照片
     *  还原，cropImage为nil
     **/
    func cropImageComplete(_ row: Int , cropImage: UIImage?)
    
    /// 设置完成按钮的状态
    func setCompleteState() -> Bool
    
    /// 点击完成事件
    func completeSelectPhoto()
    
}

/**
 *  相册图片大图预览
 */
class ZDPhotoPreviewController: UIViewController {
    
    weak var delegate: SHPhotoPreviewDelegate?
    
    override var prefersStatusBarHidden: Bool { return true }
    
    private var photoModelArr: [ZDPhotoInfoModel] = []

    private var currentIndex: Int = 0 {
        didSet{
            if self.currentIndex < 0 { self.currentIndex = 0 ; return}
            self.changedCurrentIndex()
        }
    }
    
    private let _layout = UICollectionViewFlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        _layout.scrollDirection = .horizontal
        let collec = UICollectionView(frame: CGRect.zero, collectionViewLayout: _layout)
        collec.register(ZDPhotoAssetPreviewCell.classForCoder(), forCellWithReuseIdentifier: "ZDPhotoAssetPreviewCell")
        collec.backgroundColor = UIColor.black
        collec.showsHorizontalScrollIndicator = false
        collec.showsVerticalScrollIndicator = false
        collec.scrollsToTop = false
        collec.isPagingEnabled = true
        collec.delegate = self ; collec.dataSource = self
        return collec
    }()
    
    private let bottomToolView = ZDPhotoPreviewBottomView()
    
    private let topToolView = ZDPhotoPreviewTopView()
    
    init(_ photoArr: [ZDPhotoInfoModel] , _ index: Int) {
        self.photoModelArr = photoArr
        self.currentIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configMainUI()
        self.setViewBlock()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if self.currentIndex >= 0 , self.currentIndex < photoModelArr.count {
            collectionView.setContentOffset(CGPoint(x: (self.view.frame.size.width + 20) * CGFloat(currentIndex), y: 0), animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        ZDLog("deinit: ZDPhotoPreviewController")
    }
    
}

// MARK: - logic API
extension ZDPhotoPreviewController {
    
    private func setViewBlock() {
        
        self.topToolView.handleBackAction { [weak self] actionType in
            self?.handleToolAction(actionType)
        }
        
        self.topToolView.handleSelectPhotoAction { [weak self] actionType in
            self?.handleToolAction(actionType)
        }
        
        self.bottomToolView.handleCompleteAction { [weak self] actionType in
            self?.handleToolAction(actionType)
        }
        
    }
    
    /// 处理照片预览切换
    private func changedCurrentIndex() {
        guard self.currentIndex >= 0 , self.currentIndex < photoModelArr.count else { return }
        photoModelArr[currentIndex].getOrginImageByte { [weak self] byteCount in
            self?.bottomToolView.setOriginByte(byteCount)
        }
        self.bottomToolView.isShowCropImage(photoModelArr[currentIndex].cropImage != nil)
        // 设置角标
        self.topToolView.setRightBadgValue(photoModelArr[currentIndex].selectbadgeValue)
    }
    
    /// 处理tool交互事件
    private func handleToolAction(_ actionType: ZDPreviewToolActionType) {
        switch actionType {
        case .back:
            self.navigationController?.popViewController(animated: true)
        case .completed:
            self.delegate?.completeSelectPhoto()
        case .selected:
            self.handleSelectPhotoAction()
        case .crop:
            self.startCropImageAction()
        case .revert:
            self.revertCropImage()
        }
    }
    
    /// 处理单击事件
    private func handleSingTap() {
        let _hidden = self.topToolView.isHidden
        self.topToolView.isHidden = !_hidden
        self.bottomToolView.isHidden = !_hidden
    }
    
    /// 处理选择照片事件
    private func handleSelectPhotoAction() {
        guard self.currentIndex >= 0 , self.currentIndex < photoModelArr.count else { return }
        if let result = self.delegate?.startsSelectPhoto(self.photoModelArr[currentIndex].row){
            switch result {
            case .success(let value):
                let oldValue = self.photoModelArr[currentIndex].selectbadgeValue
                self.photoModelArr[currentIndex].selectbadgeValue = value
                // 更新角标
                self.topToolView.setRightBadgValue(value , true)
                if value == nil , let _oldValue = oldValue{
                    // 取消，更新数据源
                    for i in 0 ..< self.photoModelArr.count {
                        if let currentValue = self.photoModelArr[i].selectbadgeValue , currentValue > _oldValue {
                            self.photoModelArr[i].selectbadgeValue = currentValue - 1
                        }
                    }
                }
            case .faled(let err):
                err.showToWindow()
            }
        }
        self.bottomToolView.isAbleComplete(self.delegate?.setCompleteState() ?? false)
    }
    
    private func startCropImageAction() {
        if let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? ZDPhotoAssetPreviewCell , let originImage = cell.getShowImage(){
            let cropPhotoView = ZDCropImageView(cropImage: originImage) { [weak self] image in
                self?.cropComplete(cropImage: image)
            }
            cropPhotoView.frame = self.view.bounds
            self.view.addSubview(cropPhotoView)
            self.view.bringSubviewToFront(cropPhotoView)
        
        }
    }
    
    private func cropComplete(cropImage: UIImage?) {
        guard  currentIndex >= 0 , currentIndex < self.photoModelArr.count else {
            return
        }
        if let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? ZDPhotoAssetPreviewCell {
            if let image = cropImage {
                self.delegate?.cropImageComplete(self.photoModelArr[currentIndex].row, cropImage: image)
                cell.updateCell(image: image)
                photoModelArr[currentIndex].cropImage = image
            }
            self.bottomToolView.isShowCropImage(cropImage != nil)
        }
    }
    
    private func revertCropImage() {
        guard  currentIndex >= 0 , currentIndex < self.photoModelArr.count else {
            return
        }
        self.delegate?.cropImageComplete(self.photoModelArr[currentIndex].row, cropImage: nil)
        if let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? ZDPhotoAssetPreviewCell {
            if photoModelArr[currentIndex].cropImage != nil {
                photoModelArr[currentIndex].cropImage = nil
                cell.updateCell(photoModelArr[currentIndex])
            }
            self.bottomToolView.isShowCropImage(false)
        }
       
    }
    
}


extension ZDPhotoPreviewController: UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModelArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZDPhotoAssetPreviewCell", for: indexPath) as! ZDPhotoAssetPreviewCell
        cell.updateCell(photoModelArr[indexPath.row])
        cell.handleSingleTap { [weak self] in
            self?.handleSingTap()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ZDPhotoAssetPreviewCell)?.recoverSubviews()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ZDPhotoAssetPreviewCell)?.recoverSubviews()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.currentIndex >= 0 else {
            return
        }
        // 屏幕一半距离改变下标
        let offsetWidth = scrollView.contentOffset.x + ((self.view.frame.size.width + 20) * 0.5)
        let _index = offsetWidth/(self.view.frame.size.width + 20)
        self.currentIndex = Int(_index)
    }
    
}

extension ZDPhotoPreviewController {
    
    private func configMainUI() {
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.collectionView.contentSize.width = CGFloat(self.view.frame.size.width + 20) * CGFloat(photoModelArr.count)
        self.view.addSubview(self.collectionView)
        collectionView.frame = CGRect(x: -10, y: 0, width: self.view.frame.size.width + 20, height: self.view.frame.size.height)
        _layout.itemSize = CGSize(width: self.view.frame.size.width + 20, height: self.view.frame.size.height);
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
        self.collectionView.reloadData()
        self.changedCurrentIndex()
        self.bottomToolView.isAbleComplete(self.delegate?.setCompleteState() ?? false)
        self.view.addSubview(bottomToolView)
        self.view.addSubview(topToolView)
        let vd: [String: UIView] = ["bottomToolView": bottomToolView , "topToolView": topToolView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[bottomToolView]|", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[topToolView]|", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomToolView]|", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topToolView]", options: [], metrics: nil, views: vd))
        bottomToolView.heightAnchor.constraint(equalToConstant: 48 + UIDevice.APPBOTTOMSAFEHEIGHT).isActive = true
        topToolView.heightAnchor.constraint(equalToConstant: 48 + UIDevice.APPTOPSAFEHEIGHT).isActive = true
        
       
    }
    
}
