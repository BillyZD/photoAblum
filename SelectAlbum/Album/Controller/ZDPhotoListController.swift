//
//  ZDPhotoListController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit
import Photos

/// 选择相片的结果回调
enum ZDSelectPhotoResult{
    
    case success(Int?)
    
    case faled(String)
}

/**
 *  相册列表界面
 */
class ZDPhotoListController: UIViewController , PHPhotoLibraryChangeObserver {
    
    weak var delegate: ZDSelectPhotoDelegate?
    
    struct ZDAlbumDataModel{
        
        var currentSelect: Int = 0
        
        /// 未选择的照片是否显示蒙层，不响应点击事件
        var isAllowTapUnSelectPhoto = true
        
        private (set) var albumListArr: [ZDPhotoAlbumManager.ZDAlbumModel] = []
        
        func getSelectAblum() -> ZDPhotoAlbumManager.ZDAlbumModel? {
            if self.currentSelect >= 0 , self.currentSelect < self.albumListArr.count {
                return albumListArr[currentSelect]
            }
            return nil
        }
        
        mutating func setAlbumList(_ data: [ZDPhotoAlbumManager.ZDAlbumModel]) {
            self.albumListArr = data
        }
    }
    
    private var dataModel: ZDAlbumDataModel = ZDAlbumDataModel()
    
    private var selectPhotoArr: [ZDPhotoInfoModel] = []
    
    private let navBarView: ZDPhotoNavigaTitleView = ZDPhotoNavigaTitleView()
    
    private var ablumListView: ZDPhotoAlbumAlertView?
    
    /// 当前显示的相册
    private var currentAblum: ZDPhotoAlbumManager.ZDAlbumModel?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = UIColor(hexString: "#f9f9f9")
        collection.register(ZDPhotoAssetImageCell.classForCoder(), forCellWithReuseIdentifier: "ZDPhotoAssetImageCell")
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = true
        collection.showsVerticalScrollIndicator = false
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = self.getItemSize()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        return collection
    }()
    
    private let boottomToolView: ZDPhotoListBottomView = ZDPhotoListBottomView()
    
    /// 获取图片队列
    private lazy var operationQueue: OperationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        PHPhotoLibrary.shared().register(self)
        self.setViewBlock()
        self.configMainUI()
        self.loadPhotoListData()
        
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            ZDPhotoAlbumManager.manager.isUsedCachedFirstAlbum = false
            self.loadPhotoListData()
        }
    }
    
    deinit {
        ZDLog("deinit: ZDPhotoListController")
    }
    
}

// MARK: - logic API
extension ZDPhotoListController {
    
    private func setViewBlock() {
        self.navBarView.handleTapAction { [weak self] currentSelectState in
            self?.showAlbumList(!currentSelectState)
            return !currentSelectState
        }
        self.boottomToolView.handleCompleteAction { [weak self] in
            self?.handlePreviewPhoto(false)
        } completeHandler: { [weak self] in
            self?.handleSelectComplete()
        }

    }
    
    /// 获取cell size
    private func getItemSize() -> CGSize {
        let width: CGFloat = floor((UIDevice.APPSCREENWIDTH - 5 * 3)/4)
        return CGSize(width: width, height: width)
    }
    
    /// 刷新界面
    private func reloadView(isAnimation: Bool = true) {
        if let currentAblum = self.dataModel.getSelectAblum() {
            self.currentAblum = currentAblum
        }
        if !self.selectPhotoArr.isEmpty {
            // 处理当前相册照片列表数据
            self.selectPhotoArr.forEach { model in
                if let index = self.currentAblum?.assetArr.firstIndex(of: model) {
                    self.currentAblum?.assetArr[index].selectbadgeValue = model.selectbadgeValue
                }
            }
            self.setSelectedFullState()
        }
        self.collectionView.reloadData()
        self.collectionView.performBatchUpdates {
            // 判断是否能滚动到底部
            if self.collectionView.contentSize.height > self.collectionView.frame.size.height {
                let row = (self.currentAblum?.assetArr.count ?? 1) - 1
                if row >= 0 {
                    self.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .bottom, animated: false)
                }
            }
        } completion: { _ in
            if isAnimation{
                let maxCount = self.currentAblum?.assetArr.count ?? 0
                self.collectionView.layoutIfNeeded()
                let animationCount: Int = 12
                if maxCount > animationCount {
                    var animtionCell: [UICollectionViewCell] = []
                    for row in maxCount - animationCount ..< maxCount {
                        if let cell = self.collectionView.cellForItem(at: IndexPath(row: row, section: 0)) {
                            cell.isHidden = true
                            animtionCell.append(cell)
                        }
                    }
                    var duration: TimeInterval = 0.05
                    for cell in animtionCell {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                            cell.isHidden = false
                        }
                        duration += 0.05
                    }
                }
            }
        }

        self.navBarView.setAlbumName(self.currentAblum?.albumName)
    }
    
    /// 判断权限
    private func judgeAlbumAuth() {
        switch ZDSystemAuthType.getAlbumAuthType() {
        case .restricted:
            "没有权限访问相册".showToWindow()
        case .notDetermined:
            ZDSystemAuthType.albumAuthType.requestSystemAuth(completeHandle: nil)
        case .denied:
            self.present(ZDSystemAuthType.albumAuthType.getNoAuthAlert(), animated: true, completion: nil)
        case .limited , .authorized:
            ZDLog("有权限访问")
        }
    }
    
    /// 空相册提示
    private func handleEmptyAlbum() {
        if ZDSystemAuthType.getAlbumAuthType() == .limited {
            let alert = UIAlertController(title: nil, message: "能访问照片为空，前往设置允许访问更多的照片", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "去设置", style: .default, handler: { _ in
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }else {
            "空相册".showToWindow()
        }
    }
    
    /// 设置底部工具View状态
    private func setBottomToolState() {
        self.boottomToolView.setIsEnabledState(!self.selectPhotoArr.isEmpty)
    }
    
    /// 预览照片
    private func handlePreviewPhoto(_ isPreviewAll: Bool , _ index: Int = 0) {
        let vc = ZDPhotoPreviewController(isPreviewAll ? (self.currentAblum?.assetArr ?? []) : self.selectPhotoArr , index)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 选择完成
    private func handleSelectComplete() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.delegate?.selectPHAssetsComplete(assets: self.selectPhotoArr.map({return $0.asset}))
        self.operationQueue.maxConcurrentOperationCount = 3
        var tempArr: [UIImage?] = Array(repeating: nil, count: selectPhotoArr.count)
        for i in 0 ..< self.selectPhotoArr.count {
            let operation = selectPhotoArr[i].requestImageOperation {  result in
                switch result {
                case .success(let image):
                    tempArr[i] = image
                    if tempArr.count == tempArr.compactMap({return $0}).count {
                        self.delegate?.selectPhotosImageComplete(photos: tempArr.compactMap({return $0}))
                    }
                case .failed(let err):
                    err.showToWindow()
                    tempArr.remove(at: i)
                case .preogress(let progress):
                    ZDLog(progress)
                }
            }
            self.operationQueue.addOperation(operation)
        }
    }
    
    @objc private func cancleSelectAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    
}

//MARK: - 选照片逻辑
extension ZDPhotoListController {
    
    /// 处理点击选中/取消照片事件
    private func handleSelectedPhoto(_ row: Int) -> ZDSelectPhotoResult {
        guard self.delegate?.selectMaxCount ?? 0 > 0 else {
            return ZDSelectPhotoResult.faled("不能选择照片")
        }
        if let model = self.currentAblum?.assetArr.safeIndex(row){
            if model.isSelectedState {
                // 取消选中
                self.currentAblum?.assetArr[row].selectbadgeValue = nil
                if let cell = collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? ZDPhotoAssetImageCell {
                    cell.setRightBagdValue(nil)
                }
                if let selectIndex = self.selectPhotoArr.firstIndex(of: model) {
                    // 处理角标
                    self.handleCancleSelectedBagdValue(selectIndex: selectIndex)
                    self.selectPhotoArr.remove(at: selectIndex)
                }
                self.setSelectedFullState()
            }else if isAllowSelected(){
                // 允许选中
                // 设置选中的角标
                self.currentAblum?.assetArr[row].selectbadgeValue = self.selectPhotoArr.count + 1
                // 保存选中的相片
                self.selectPhotoArr.append(self.currentAblum!.assetArr[row])
                // 判断是否选满
                self.setSelectedFullState()
                self.setBottomToolState()
                return ZDSelectPhotoResult.success(self.selectPhotoArr.count)
            }else {
                return ZDSelectPhotoResult.faled("最多只能选择\(self.delegate?.selectMaxCount ?? 0)张照片")
            }
        }
        self.setBottomToolState()
        return ZDSelectPhotoResult.success(nil)
    }
    
    /// 判断是否允许被选中
    private func isAllowSelected() -> Bool {
        return self.delegate?.selectMaxCount ?? 0 > self.selectPhotoArr.count
    }
    
    /// 判断并设置选满状态
    private func setSelectedFullState() {
        if self.delegate?.selectMaxCount ?? 0 == self.selectPhotoArr.count {
            self.dataModel.isAllowTapUnSelectPhoto = false
            // 设置可见cell的蒙层状态
            if let cells = self.collectionView.visibleCells as? [ZDPhotoAssetImageCell] {
                cells.forEach { cell in
                    let isSelect = self.selectPhotoArr.contains(where: {$0.asset.localIdentifier == cell.localIdentifier()})
                    cell.setShowMaskState(!isSelect)
                }
            }
        }else {
            if self.dataModel.isAllowTapUnSelectPhoto == false {
                self.dataModel.isAllowTapUnSelectPhoto = true
                if let cells = collectionView.visibleCells as? [ZDPhotoAssetImageCell] {
                    cells.forEach({$0.setShowMaskState(false)})
                }
            }
            
        }
    }
    
    /// 处理取消照片后的角标逻辑
    private func handleCancleSelectedBagdValue(selectIndex: Int) {
        guard selectIndex >= 0 , selectIndex < selectPhotoArr.count else { return }
        // 大于selectIndex的角标需要减1
        for i in (selectIndex + 1) ..< selectPhotoArr.count {
            // 选中的角标
            let selectedBadge = selectPhotoArr[i].selectbadgeValue ?? 2
            // 界面展示的位置
            let listIndex = self.selectPhotoArr[i].row
            if listIndex <  self.currentAblum?.assetArr.count ?? 0 , listIndex >= 0 {
                self.currentAblum?.assetArr[listIndex].selectbadgeValue = selectedBadge - 1
            }
            selectPhotoArr[i].selectbadgeValue = selectedBadge - 1
            if let cell = collectionView.cellForItem(at: IndexPath(row: listIndex, section: 0)) as? ZDPhotoAssetImageCell {
                cell.setRightBagdValue(selectedBadge - 1)
            }
        }
    }
    
    /// 是否需要展示蒙层
    private func isSetMaskView(_ row: Int) -> Bool {
        guard row >= 0 , row < self.currentAblum?.assetArr.count ?? 0 else { return false}
        if self.dataModel.isAllowTapUnSelectPhoto == false {
            if selectPhotoArr.contains(where: {$0 == self.currentAblum?.assetArr[row]}) == false {
                return true
            }
        }
        return false
    }
    
}

//MARK: - 选相册逻辑
extension ZDPhotoListController {
    
    private func showAlbumList(_ isShow: Bool) {
        if isShow {
            self.ablumListView = ZDPhotoAlbumAlertView.showAlbumListAlert(containtView: self.view, albumArr: self.dataModel.albumListArr, selectIndex: self.dataModel.currentSelect){ [weak self] selectIndex in
                if selectIndex != self?.dataModel.currentSelect {
                    self?.dataModel.currentSelect = selectIndex
                    self?.reloadView()
                }else {
                    // 通过更新名称，刷新顶部选中状态
                    self?.navBarView.setAlbumName(self?.currentAblum?.albumName)
                }
                
                self?.ablumListView?.isShowAlert(false, completion: {
                    self?.ablumListView = nil
                })
            }
           
        }else {
            self.ablumListView?.isShowAlert(false, completion: { [weak self] in
                self?.ablumListView = nil
            })
        }
    }
}

//MARK: - 预览界面代理事件回调
extension ZDPhotoListController: SHPhotoPreviewDelegate {
    
    func startsSelectPhoto(_ row: Int) -> ZDSelectPhotoResult {
        let res = self.handleSelectedPhoto(row)
        if case ZDSelectPhotoResult.success = res {
            if let cell = self.collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? ZDPhotoAssetImageCell {
                cell.setRightBagdValue(self.currentAblum?.assetArr[row].selectbadgeValue)
            }
        }
        return res
    }
    
    func setCompleteState() -> Bool {
        return !self.selectPhotoArr.isEmpty
    }
    
    func completeSelectPhoto() {
        self.handleSelectComplete()
    }
    
}

extension ZDPhotoListController: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !self.isSetMaskView(indexPath.row) {
            self.handlePreviewPhoto(true , indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentAblum?.assetArr.count ?? 0
    }
    
    func  collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZDPhotoAssetImageCell", for: indexPath) as! ZDPhotoAssetImageCell
        if let model = self.currentAblum?.assetArr[indexPath.row] {
            cell.updateCell(model)
        }
        cell.handleSelectedAction { [weak self] in
            if let res = self?.handleSelectedPhoto(indexPath.row) {
                switch res {
                case .success(let index):
                    return index
                case .faled(let string):
                    string.showToWindow()
                }
            }
            return nil
        }
        cell.setShowMaskState(self.isSetMaskView(indexPath.row))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row < self.currentAblum?.assetArr.count ?? 0 else { return }
        (cell as? ZDPhotoAssetImageCell)?.setShowMaskState(self.isSetMaskView(indexPath.row))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row < self.currentAblum?.assetArr.count ?? 0 else { return }
        
        (cell as? ZDPhotoAssetImageCell)?.setShowMaskState(self.isSetMaskView(indexPath.row))
    }
    
}


// MARK: - data API
extension ZDPhotoListController {
    
    /// 加载照片和相册
    private func loadPhotoListData() {
        
        guard ZDSystemAuthType.albumAuthType.isAuthorization() else {
            self.judgeAlbumAuth()
            return
        }
        
       // ZDPhotoAlbumManager.manager.isUsedCachedFirstAlbum = false
        ZDPhotoAlbumManager.getFirstCameraAlbum { [weak self] model in
            if let _model = model , self?.currentAblum == nil {
                self?.currentAblum = _model
                self?.reloadView(isAnimation: false)
            }
        }
        
        ZDPhotoAlbumManager.getAllCamerAlbum { [weak self] albumArr in
            if albumArr.isEmpty {
                self?.handleEmptyAlbum()
            }else {
                self?.dataModel.setAlbumList(albumArr)
                if self?.dataModel.getSelectAblum() != self?.currentAblum || self?.currentAblum == nil {
                    // 刷新界面
                    self?.reloadView(isAnimation: false)
                }
            }
        }
    }
    
}

// MARK: - UI API
extension ZDPhotoListController {
    
    private func configMainUI() {
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.navigationItem.titleView = self.navBarView
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.boottomToolView)
        let vd: [String: UIView] = ["collectionView": collectionView , "boottomToolView": boottomToolView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[collectionView]|", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[boottomToolView]|", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView][boottomToolView(\(48 + UIDevice.APPBOTTOMSAFEHEIGHT))]|", options: [], metrics: nil, views: vd))
        configItem()
    }
    
    private func configItem() {
        let rightItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancleSelectAction))
        rightItem.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(hexString: "#333333")], for: .normal)
        rightItem.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(hexString: "#333333") ], for: .highlighted)
        self.navigationItem.rightBarButtonItem = rightItem
    }
}
