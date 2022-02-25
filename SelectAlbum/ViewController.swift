//
//  ViewController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/11.
//

import UIKit
import Photos


class ViewController: UIViewController {
    
    let lab = YYFPSLabel(frame: CGRect(x: 300, y: 40, width: 60, height: 30))
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(ZDSelectImageCell.classForCoder(), forCellWithReuseIdentifier: "ZDSelectImageCell")
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor(hexString: "#F9F9F9")
        collection.alwaysBounceVertical = true
        collection.showsVerticalScrollIndicator = false
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = self.getItemSize()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        return collection
    }()
    
    private var selectImageArr: [UIImage] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.APPWINDOW.addSubview(lab)
        self.view.backgroundColor = UIColor.white
        self.configMainUI()
        // Do any additional setup after loading the view.
        let filed = UITextField() ; filed.borderStyle = .line
        filed.placeholder = "输入关键字"
        self.view.addSubview(filed)
        filed.translatesAutoresizingMaskIntoConstraints = false
        let vd: [String: UIView] = ["filed": filed]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[filed(\(self.view.frame.size.width - 40))]", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-300-[filed(40)]", options: [], metrics: nil, views: vd))
        let centerContrins = filed.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
        centerContrins.isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            centerContrins.constant  = -(self.view.frame.size.width - 40)/2
            filed.transform = CGAffineTransform(scaleX: 0.1, y: 1)
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 5, delay: 0, options: .curveEaseInOut) {
                centerContrins.constant = 0
                filed.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.view.layoutIfNeeded()
            } completion: { _ in
                filed.transform = CGAffineTransform.identity
            }

        }
    }
    
    @objc private func clickSelectPhoto() {
        self.presentPhotoList(self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            UIDevice.APPWINDOW.bringSubviewToFront(self.lab)
        }
    }
    
    private func deleteSeletPhoto(_ row: Int) {
        self.collectionView.performBatchUpdates {
            if row < self.selectImageArr.count , row >= 0 {
                self.selectImageArr.remove(at: row)
            }else {
                return
            }
            self.collectionView.deleteItems(at: [IndexPath(row: row, section: 0)])
            
        } completion: { _ in
            self.collectionView.reloadData()
        }
    }
    
    private func getItemSize() -> CGSize {
        return CGSize(width: floor((UIDevice.APPSCREENWIDTH - 5 * 3)/4), height: floor((UIDevice.APPSCREENWIDTH - 5 * 3)/4))
    }
    
}

extension ViewController: ZDSelectPhotoDelegate {

    var selectMaxCount: Int {
        return 9 - self.selectImageArr.count
    }
    
    func selectPhotosImageComplete(photos: [UIImage]) {
        self.selectImageArr.append(contentsOf: photos)
        self.collectionView.reloadData()

    }
    
    
    func selectPHAssetsComplete(assets: [PHAsset]) {
        assets.forEach { asset in
//            asset.requestContentEditingInput(with: nil) { input, info in
//                if let url = input?.fullSizeImageURL  {
//                    if let image = UIImage.scaleImage(newWidth: 600, url: url) {
//                        ZDLog(image.size)
//                        self.selectImageArr.append(image)
//                        self.collectionView.reloadData()
//                    }
//                }else {
//                    ZDLog("11")
//                }
//            }
            
            
            ZDPhotoImageManager.getOriginImageData(asset, resultHandler: { data, UTI, _, info in
                ZDLog(UTI ?? "" )
                if let _data = data {
                    let values = [UInt8](_data)
                   // self.selectImageArr.append(UIImage(data: _data)!)
                    debugPrint(values[0] , "原图大小:\(_data.count)")
//                    debugPrint(UIImage(data: _data)!.size)
//                    if values[0] == 0x00 {
//                        if let ciImage = CIImage(data: _data) {
//                            let context = CIContext()
//                            let jpgData = context.jpegRepresentation(of: ciImage, colorSpace: ciImage.colorSpace!, options: [:])
//                            let jpgValues = [UInt8](jpgData!)
//                            debugPrint(jpgValues[0] , "jpg:\(jpgData!.count)")
//                        }
//                    }
                }

//                if let _data = data {
//                    let values = [UInt8](_data)
//                    ZDLog(values[0])
//                    if values[0] == 0x47 {
//                        // gif
//                        if let image = UIImage.initGIFImage(gifData: _data) {
//                            if let data = image.pngData() {
//                                let values = [UInt8](data)
//                                debugPrint(values[0] , "pngCount:\(data.count)")
//
//                            }
//                            if let data = image.jpegData(compressionQuality: 0.9) {
//                                let values = [UInt8](data)
//                                debugPrint(values[0] , data.count)
//
//                            }
//                        }
//                    }
//                }
            }, progressHandler: nil)
        }
    }
}

extension ViewController:  UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            let rect = collectionView.convert(cell.frame, to: UIDevice.APPWINDOW)
            let vc = ZDImageBrowerController(self.selectImageArr, startIndex: indexPath.row) { row in
                if let _cell = collectionView.cellForItem(at: IndexPath(item: row, section: 0)) as? ZDSelectImageCell {
                    return collectionView.convert(_cell.frame, to: UIDevice.APPWINDOW)
                }
                return nil
            }
            vc.showImageBrower(self, startRect: rect)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectImageArr.count
    }
    
    func  collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZDSelectImageCell", for: indexPath) as! ZDSelectImageCell
        cell.imageView.setImage(selectImageArr[indexPath.row], size: self.getItemSize(), radius: 8)
        cell.deleteHandler = { [weak self] in
            self?.deleteSeletPhoto(indexPath.row)
        }
        return cell
    }
    
}

extension ViewController {
    
    private func configMainUI() {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("选择照片", for: .normal)
        button.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        
        button.addTarget(self, action: #selector(clickSelectPhoto), for: .touchUpInside)
        self.view.addSubview(button)
        self.view.addSubview(collectionView)
        let vd: [String: UIView] = ["button": button , "collectionView": collectionView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[button(100)]", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[collectionView]|", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[button(35)][collectionView(200)]", options: [], metrics: nil, views: vd))
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
    }
    
}


class ZDSelectImageCell: UICollectionViewCell {
    
    var imageView: UIImageView  = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    var deleteHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.setTitle("X", for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        deleteButton.setTitleColor(UIColor(hexString: "#FF813B"), for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.backgroundColor = UIColor(hexString: "#999999")
        deleteButton.layer.cornerRadius = 8 ; deleteButton.layer.masksToBounds = true
        deleteButton.addTarget(self, action: #selector(clickDeleteButtonAction), for: .touchUpInside)
        
        contentView.addSubview(imageView)
      //  contentView.addSubview(deleteButton)
        let vd: [String: UIView] = ["imageView": imageView , "deleteButton": deleteButton]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[imageView]|", options: [], metrics: nil, views: vd))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: vd))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clickDeleteButtonAction() {
        deleteHandler?()
    }
    
}


class TestCropController: UIViewController {
   
    var image: UIImage?
    
    private var cropView: ZDCropRectView = ZDCropRectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        cropView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cropView)
        let vd: [String: UIView] = ["cropView": cropView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[cropView]|", options: [], metrics: nil, views: vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cropView]|", options: [], metrics: nil, views: vd))
        debugPrint(self.view.frame , cropView.frame , "viewDidLoad")
        
        guard let cropImage = image else {
            return
        }
        
        let imageView = UIImageView(image: cropImage)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        let _vd: [String: UIView] = ["imageView": imageView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[imageView]|", options: [], metrics: nil, views: _vd))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: _vd))
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        debugPrint(self.view.frame , "viewSafeAreaInsetsDidChange")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        debugPrint(self.view.frame , "viewDidLayoutSubviews")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        debugPrint(self.view.frame , "viewWillLayoutSubviews")
    }
}
