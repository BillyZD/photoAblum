//
//  ZDImageBrowerController.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/21.
//

import Foundation

class ZDImageBrowerController: UIViewController {
    
    private let presentAnimation = ZDPresentAnimationModel()
    
    private var dissmissRectHandle: ((Int) -> CGRect?)?
    
    private var imageArr: [UIImage] = []
    
    private let _layout = UICollectionViewFlowLayout()
    
    private var currentIndex: Int = 0 {
        didSet{
            if currentIndex < 0 || currentIndex > imageArr.count {
                currentIndex = 0
            }
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        _layout.scrollDirection = .horizontal
        let collec = UICollectionView(frame: CGRect.zero, collectionViewLayout: _layout)
        collec.register(ZDImageBrowerCell.classForCoder(), forCellWithReuseIdentifier: "ZDImageBrowerCell")
        collec.showsHorizontalScrollIndicator = false
        collec.showsVerticalScrollIndicator = false
        collec.scrollsToTop = false
        collec.isPagingEnabled = true
        collec.backgroundColor = UIColor.clear
        collec.delegate = self ; collec.dataSource = self
        return collec
    }()
    
    init(_ imageArr: [UIImage] , startIndex: Int , handler: ((Int) -> CGRect?)? ) {
        super.init(nibName: nil, bundle: nil)
        self.dissmissRectHandle = handler
        self.imageArr = imageArr
        self.currentIndex = startIndex
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.configMainUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if self.currentIndex >= 0 , self.currentIndex < imageArr.count {
            collectionView.setContentOffset(CGPoint(x: (self.view.frame.size.width + 20) * CGFloat(currentIndex), y: 0), animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        ZDLog("deint:ZDImageBrowerController")
    }
    
    func showImageBrower(_ fromVC: UIViewController , startRect: CGRect) {
        self.presentAnimation.presentController(fromVC: fromVC, toVC: self, rect: startRect)
    }
    
}

extension ZDImageBrowerController: UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZDImageBrowerCell", for: indexPath) as! ZDImageBrowerCell
        cell.updateCell(imageArr[indexPath.row])
        cell.handleSingleTap { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
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

extension ZDImageBrowerController: ZDDissAnimationProtocol{
    
    func getDissAnimationView() -> UIView? {
        if let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? ZDImageBrowerCell {
            return cell.getAnimationView()
        }
        return nil
    }
    
    func getDissAnimationRect() -> CGRect?{
        return self.dissmissRectHandle?(currentIndex)
    }
}

extension ZDImageBrowerController {
    
    private func configMainUI() {
       
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.collectionView.contentSize.width = CGFloat(self.view.frame.size.width + 20) * CGFloat(imageArr.count)
        self.view.addSubview(self.collectionView)
        collectionView.frame = CGRect(x: -10, y: 0, width: self.view.frame.size.width + 20, height: self.view.frame.size.height)
        _layout.itemSize = CGSize(width: self.view.frame.size.width + 20, height: self.view.frame.size.height);
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
        self.collectionView.reloadData()
        
    }
    
}
