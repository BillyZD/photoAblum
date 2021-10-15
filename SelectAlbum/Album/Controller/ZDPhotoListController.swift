//
//  ZDPhotoListController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/12.
//

import UIKit
import Photos

/**
 *  相册列表界面
 */
class ZDPhotoListController: UIViewController , PHPhotoLibraryChangeObserver {
    
    struct ZDAlbumDataModel{
        
        var currentSelect: Int = 0
        
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
    
    private var selectedMaxCount: Int = 2
    
    private var dataModel: ZDAlbumDataModel = ZDAlbumDataModel()
    
    private var selectPhotoArr: [ZDPhotoInfoModel] = []
    
    private let navBarView: ZDPhotoNavigaTitleView = ZDPhotoNavigaTitleView()
    
    private var ablumListView: ZDPhotoAlbumAlertView?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = UIColor(hexString: "#f9f9f9")
        collection.register(ZDPhotoAssetImageCell.classForCoder(), forCellWithReuseIdentifier: "ZDPhotoAssetImageCell")
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = false
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = self.getItemSize()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        return collection
    }()
    
    /// 当前显示的相册
    private var currentAblum: ZDPhotoAlbumManager.ZDAlbumModel?
    
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
        debugPrint("deinit: ZDPhotoListController")
    }
    
}

// MARK: - logic API
extension ZDPhotoListController {
    
    private func setViewBlock() {
        self.navBarView.handleTapAction { [weak self] currentSelectState in
            self?.showAlbumList(!currentSelectState)
            return !currentSelectState
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
            
        } completion: { _ in
            // 判断是否能滚动到底部
            if self.collectionView.contentSize.height > self.collectionView.frame.size.height {
                let row = (self.currentAblum?.assetArr.count ?? 1) - 1
                if row >= 0 {
                    self.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .bottom, animated: false)
                }
            }
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
        switch ZDSystemAuthType.albumAuthType.getAlbumAuthType() {
        case .restricted:
            "没有权限访问相册".showToWindow()
        case .notDetermined:
            ZDSystemAuthType.albumAuthType.requestSystemAuth(completeHandle: nil)
        case .denied:
            self.present(ZDSystemAuthType.albumAuthType.getNoAuthAlert(), animated: true, completion: nil)
        case .limited , .authorized:
            debugPrint("有权限访问")
        }
    }
    
    /// 空相册提示
    private func handleEmptyAlbum() {
        if ZDSystemAuthType.albumAuthType.getAlbumAuthType() == .limited {
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
    
    @objc private func cancleSelectAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - 选照片逻辑
extension ZDPhotoListController {
    
    /// 处理点击选中/取消照片事件
    private func handleSelectedPhoto(_ row: Int) -> Int? {
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
                self.currentAblum?.assetArr[row].isAllowTap = true
                // 保存选中的相片
                self.selectPhotoArr.append(self.currentAblum!.assetArr[row])
                // 判断是否选满
                self.setSelectedFullState()
                return self.selectPhotoArr.count
            }else {
                "最多只能选择\(selectedMaxCount)张照片".showToWindow()
            }
        }
        
        return nil
    }
    
    /// 判断是否允许被选中
    private func isAllowSelected() -> Bool {
    
        return self.selectedMaxCount > self.selectPhotoArr.count
    }
    
    /// 判断并设置选满状态
    private func setSelectedFullState() {
        if self.selectedMaxCount == self.selectPhotoArr.count {
            // 设置列表数据源
            if let phototArr = self.currentAblum?.assetArr {
                for i in 0 ..< phototArr.count {
                    if self.selectPhotoArr.contains(where: {$0 == phototArr[i]}) {
                        self.currentAblum?.assetArr[i].isAllowTap = true
                    }else {
                        self.currentAblum?.assetArr[i].isAllowTap = false
                    }
                }
            }
            // 设置可见cell的蒙层状态
            if let cells = collectionView.visibleCells as? [ZDPhotoAssetImageCell] {
                cells.forEach { cell in
                    let isSelect = self.selectPhotoArr.contains(where: {$0.asset.localIdentifier == cell.localIdentifier()})
                    cell.setShowMaskState(!isSelect)
                }
            }
        }else {
            if self.currentAblum?.assetArr.contains(where: {$0.isAllowTap == false}) == true {
                if let phototArr = self.currentAblum?.assetArr {
                    self.currentAblum?.assetArr = phototArr.map({ model in
                        if model.isAllowTap { return model }
                        var _model = model ; _model.isAllowTap = true
                        return _model
                    })
                }
            }
            if let cells = collectionView.visibleCells as? [ZDPhotoAssetImageCell] {
                cells.forEach({$0.setShowMaskState(false)})
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

extension ZDPhotoListController: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.currentAblum?.assetArr[indexPath.row].isAllowTap == true else { return }
        let vc = ZDPhotoPreviewController(self.currentAblum?.assetArr ?? [])
        self.navigationController?.pushViewController(vc, animated: true)
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
            return self?.handleSelectedPhoto(indexPath.row)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row < self.currentAblum?.assetArr.count ?? 0 else { return }
        let isAllowTap = self.currentAblum?.assetArr[indexPath.row].isAllowTap ?? false
        (cell as? ZDPhotoAssetImageCell)?.setShowMaskState(!isAllowTap)
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
        
        ZDPhotoAlbumManager.manager.isUsedCachedFirstAlbum = false
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
        self.navigationItem.titleView = self.navBarView
        self.view.addSubview(self.collectionView)
        let vd: [String: UIView] = ["collectionView": collectionView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[collectionView]|", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: vd))
        configItem()
    }
    
    private func configItem() {
        let rightItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancleSelectAction))
        rightItem.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(hexString: "#333333")], for: .normal)
        rightItem.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(hexString: "#333333") ], for: .highlighted)
        self.navigationItem.rightBarButtonItem = rightItem
    }
}
