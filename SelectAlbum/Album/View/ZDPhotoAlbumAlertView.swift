//
//  ZDPhotoAlbumListView.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/15.
//

import UIKit

/**
 *  相册列表弹框View
 */
class ZDPhotoAlbumAlertView: UIView {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = UIColor.white
        table.register(ZDPhotoAlbumListCell.classForCoder(), forCellReuseIdentifier: "ZDPhotoAlbumListCell")
        table.separatorStyle = .none
        return table
    }()
    
    private var tableHeightConstraint: NSLayoutConstraint?
    
    private let cellHeight: CGFloat = 65
    
    private var selectIndex: Int = 0
    
    private var selectIndexHandler: ((Int) -> Void)?
    
    private var dataArr: [ZDPhotoAlbumManager.ZDAlbumModel] = []{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configMainUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            let convertPoint = self.convert(point, to: self.tableView)
            if !self.tableView.bounds.contains(convertPoint) {
                selectIndexHandler?(self.selectIndex)
            }
        }
    }
    
    deinit{
        ZDLog("deint: ZDPhotoAlbumAlertView")
    }
    
}

extension ZDPhotoAlbumAlertView {
    
    static func showAlbumListAlert(containtView: UIView , albumArr: [ZDPhotoAlbumManager.ZDAlbumModel] ,selectIndex: Int , completion: ((Int) -> Void)?) -> ZDPhotoAlbumAlertView? {
        guard albumArr.count > 0 else { return nil }
        let alertView = ZDPhotoAlbumAlertView()
        containtView.addSubview(alertView)
        alertView.frame = containtView.bounds
        alertView.selectIndex = selectIndex
        alertView.dataArr = albumArr
        alertView.isShowAlert(true)
        alertView.selectIndexHandler = completion
        return alertView
    }
    
    func isShowAlert(_ isShow: Bool , completion: (() -> Void)? = nil){
        self.layoutIfNeeded()
        if !isShow {self.backgroundColor = UIColor.clear}
        let height = self.getTableHeight()
        UIView.animate(withDuration: 0.25) {
            self.tableHeightConstraint?.constant = isShow ? height : 0
            self.layoutIfNeeded()
        } completion: { _ in
            if !isShow {
                self.removeFromSuperview()
            }
            completion?()
        }

    }
    
    private func getTableHeight() -> CGFloat {
        return self.cellHeight * CGFloat(min(6, self.dataArr.count))
    }
    
}

extension ZDPhotoAlbumAlertView: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndexHandler?(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ZDPhotoAlbumListCell", for: indexPath) as! ZDPhotoAlbumListCell
        cell.updateCell(dataArr[indexPath.row])
//        if indexPath.row == selectIndex {
//            cell.accessoryType = .checkmark
//        }else {
//            cell.accessoryType = .none
//        }
        return cell
    }
}


extension ZDPhotoAlbumAlertView {
    
    private func configMainUI() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.tableView.delegate = self ; self.tableView.dataSource = self
        self.addSubview(tableView)
        let vd: [String: UIView] = ["tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: [], metrics: nil, views: vd))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]", options: [], metrics: nil, views: vd))
        self.tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        self.tableHeightConstraint?.isActive = true
    }
    
}


private class ZDPhotoAlbumListCell: UITableViewCell {
    
    private let albumCoverImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel() ; label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16) ; label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    private let albumPhotoCountLabel: UILabel = {
        let label = UILabel() ; label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14) ; label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    private let separeLine: UIView = {
        let line = UIView() ; line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(hexString: "#E4E4E4")
        return line
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addSubview(albumCoverImage)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(albumPhotoCountLabel)
        contentView.addSubview(separeLine)
        let vd: [String: UIView] = ["albumCoverImage":albumCoverImage , "albumNameLabel": albumNameLabel , "albumPhotoCountLabel": albumPhotoCountLabel , "separeLine": separeLine]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[albumCoverImage(50)]-[albumNameLabel(<=250)][albumPhotoCountLabel]", options: [.alignAllCenterY], metrics: nil, views: vd))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[separeLine]|", options: [], metrics: nil, views: vd))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[separeLine(0.5)]|", options: [], metrics: nil, views: vd))
        albumCoverImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        albumCoverImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ model: ZDPhotoAlbumManager.ZDAlbumModel) {
        model.getCoverImage { [weak self] image in
            self?.albumCoverImage.image = image
        }
        albumNameLabel.text = model.albumName
        albumPhotoCountLabel.text = "(\(model.assetArr.count))"
    }
}
