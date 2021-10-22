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
        layout.itemSize = CGSize(width: floor((UIDevice.APPSCREENWIDTH - 5 * 3)/4), height: floor((UIDevice.APPSCREENWIDTH - 5 * 3)/4))
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
    }
    
    @objc private func clickSelectPhoto() {
        self.presentPhotoList(self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            UIDevice.APPWINDOW.bringSubviewToFront(self.lab)
        }
    }
    
    private func deleteSeletPhoto(_ row: Int) {
        self.collectionView.performBatchUpdates {
            if row < self.selectImageArr.count {
                self.selectImageArr.remove(at: row)
            }
            self.collectionView.deleteItems(at: [IndexPath(row: row, section: 0)])
            
        } completion: { _ in
            self.collectionView.reloadData()
        }

    }
}

extension ViewController: ZDSelectPhotoDelegate {
    
    var selectMaxCount: Int {
        return 9 - self.selectImageArr.count
    }
    
    func selectPhotosComplete(photos: [UIImage]) {
        self.selectImageArr.append(contentsOf: photos)
        self.collectionView.reloadData()
    }
    
    func selectPHAssetsComplete(assets: [PHAsset]) {
        assets.forEach { asset in
          //  debugPrint(asset.value(forKey: "filename"))
            ZDPhotoImageManager.getOriginImageData(asset, resultHandler: { data, _, _, _ in
                if let _data = data {
                    let values = [UInt8](_data)
                    if values[0] == 0x47 {
                        // gif
                        if let image = UIImage.initGIFImage(gifData: _data) {
                            if let data = image.pngData() {
                                let values = [UInt8](data)
                                debugPrint(values[0] , "pngCount:\(data.count)")
                                
                            }
                            if let data = image.jpegData(compressionQuality: 0.9) {
                                let values = [UInt8](data)
                                debugPrint(values[0] , data.count)
                                
                            }
                        }
                    }


                }
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
        cell.imageView.image = selectImageArr[indexPath.row]
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
        contentView.addSubview(deleteButton)
        let vd: [String: UIView] = ["imageView": imageView , "deleteButton": deleteButton]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[imageView]-(-8)-[deleteButton(16)]|", options: [], metrics: nil, views: vd))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[deleteButton(16)]-(-8)-[imageView]|", options: [], metrics: nil, views: vd))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clickDeleteButtonAction() {
        deleteHandler?()
    }
    
}
