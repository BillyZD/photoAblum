//
//  ZDPhotoPreviewController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/13.
//

import UIKit

/**
 *  相册图片大图预览
 */
class ZDPhotoPreviewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool { return true }
    
    private var photoModelArr: [ZDPhotoInfoModel] = []
    
    private var currentIndex: Int = 0 {
        didSet{
            self.changedCurrentIndex()
        }
    }
    
    private let _layout = UICollectionViewFlowLayout()


    private lazy var collectionView: UICollectionView = {
        _layout.scrollDirection = .horizontal
        let collec = UICollectionView(frame: CGRect.zero, collectionViewLayout: _layout)
        collec.backgroundColor = UIColor(hexString: "#F9F9F9")
        collec.register(ZDPhotoAssetPreviewCell.classForCoder(), forCellWithReuseIdentifier: "ZDPhotoAssetPreviewCell")
        collec.backgroundColor = UIColor.black
        collec.showsHorizontalScrollIndicator = false
        collec.showsVerticalScrollIndicator = false
        collec.scrollsToTop = false
        collec.isPagingEnabled = true
        collec.delegate = self ; collec.dataSource = self
        return collec
    }()
    
    private let bottomToolView = ZDPhotoBrowerBottomView()
    
    private let topToolView = ZDPhotoBrowerTopView()
    
    init(_ photoArr: [ZDPhotoInfoModel]) {
        self.photoModelArr = photoArr
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: -10, y: 0, width: self.view.frame.size.width + 20, height: self.view.frame.size.height)
        _layout.itemSize = CGSize(width: self.view.frame.size.width + 20, height: self.view.frame.size.height);
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
    }
    
}

// MARK: - logic API
extension ZDPhotoPreviewController {
    
    func setViewBlock() {
        
        self.topToolView.handleBackAction { [weak self] actionType in
            self?.handleToolAction(actionType)
        }
        
        self.bottomToolView.handleCompleteAction { [weak self] actionType in
            self?.handleToolAction(actionType)
        }
    }
    
    /// 处理滑动切换
    func changedCurrentIndex() {
        guard self.currentIndex >= 0 , self.currentIndex < photoModelArr.count else { return }
        photoModelArr[currentIndex].getOrginImageByte { [weak self] byteCount in
            self?.bottomToolView.setOriginByte(byteCount)
        }
    }
    
    /// 处理tool交互事件
    private func handleToolAction(_ actionType: ZDBrowerToolActionType) {
        switch actionType {
        case .back:
            self.navigationController?.popViewController(animated: true)
        case .completed:
            "点击完成".showToWindow()
        case .selected:
            "点击选择/取消".showToWindow()
        }
    }
    
    /// 处理单击事件
    private func handleSingTap() {
        let _hidden = self.topToolView.isHidden
        self.topToolView.isHidden = !_hidden
        self.bottomToolView.isHidden = !_hidden
    }
    
}


extension ZDPhotoPreviewController: UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.handleSingTap()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModelArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZDPhotoAssetPreviewCell", for: indexPath) as! ZDPhotoAssetPreviewCell
        cell.updateCell(photoModelArr[indexPath.row])
        return cell
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
        self.view.addSubview(self.collectionView)
        self.collectionView.reloadData()
        self.changedCurrentIndex()
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
