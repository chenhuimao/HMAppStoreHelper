//
//  AppInfoCell.swift
//  HMAppStoreHelper
//
//  Created by CHM on 2019/5/17.
//  Copyright © 2019 陈晖茂. All rights reserved.
//

import UIKit

extension AppInfoCell {
    class func makeOrReusedCell(inTableView tableView: UITableView) -> AppInfoCell {
        let id = "AppInfoCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? AppInfoCell
        if cell == nil {
            cell = AppInfoCell.init(style: .default, reuseIdentifier: id)
        }
        
        return cell!
    }
    
    class var height: CGFloat {
        return 50
    }
    
    func setup(appInfo: AppInfo) {
        self.appInfo = appInfo

        self.requestIconImage()
        self.nameLab.text = appInfo.name
        self.versionLab.text = appInfo.version
        self.dateLab.text = appInfo.releaseDate
        self.ratingLab.text = String.init(format: "⭐️%.1lf(%zd)", appInfo.averageRating, appInfo.userRatingCount)
        
        if appInfo.isUpdated {
            self.versionLab.textColor = UIColor.red
            self.dateLab.textColor = UIColor.red
        }
        
        self.setNeedsLayout()
    }
}

class AppInfoCell: UITableViewCell {
    
    private var appInfo: AppInfo?
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.layer.cornerRadius = 6
        icon.layer.masksToBounds = true
        return icon
    }()
    
    private let nameLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.black
        lab.font = UIFont.systemFont(ofSize: 16)
        return lab
    }()
    
    private let versionLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        lab.font = UIFont.systemFont(ofSize: 14)
        return lab
    }()
    
    private let dateLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        lab.font = UIFont.systemFont(ofSize: 14)
        return lab
    }()
    
    /// 评分label
    private let ratingLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        lab.font = UIFont.systemFont(ofSize: 14)
        return lab
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator

        self.contentView.addSubview(self.icon)
        self.contentView.addSubview(self.nameLab)
        self.contentView.addSubview(self.versionLab)
        self.contentView.addSubview(self.dateLab)
        self.contentView.addSubview(self.ratingLab)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let marginX: CGFloat = 10
        let marginY: CGFloat = 5
        let iconSidelength: CGFloat = 30
        self.icon.frame = CGRect.init(x: marginX, y: (self.contentView.bounds.height - iconSidelength) / 2, width: iconSidelength, height: iconSidelength)
        self.nameLab.frame = CGRect.init(x: self.icon.frame.maxX + marginX, y: 0, width: self.nameLab.intrinsicContentSize.width, height: self.contentView.bounds.height)
        
        self.versionLab.frame = CGRect.init(x: self.contentView.bounds.width - marginX - self.versionLab.intrinsicContentSize.width, y: marginY, width: self.versionLab.intrinsicContentSize.width, height: self.versionLab.intrinsicContentSize.height)
        self.dateLab.frame = CGRect.init(x: self.contentView.bounds.width - marginX - self.dateLab.intrinsicContentSize.width, y: self.contentView.bounds.height - marginY - self.dateLab.intrinsicContentSize.height, width: self.dateLab.intrinsicContentSize.width, height: self.dateLab.intrinsicContentSize.height)
        self.ratingLab.frame = CGRect.init(x: self.dateLab.frame.minX - 10 - self.ratingLab.intrinsicContentSize.width, y: self.dateLab.frame.minY, width: self.ratingLab.intrinsicContentSize.width, height: self.ratingLab.intrinsicContentSize.height)

    }
    
    private func requestIconImage() {
        //  还需要完善cancel机制
        self.icon.image = nil
        DispatchQueue.global().async {
            guard let url = URL.init(string: self.appInfo?.imageURL ?? "") else {
                return
            }
            guard let imageData = try? Data.init(contentsOf: url) else {
                return
            }
            
            DispatchQueue.main.async {
                self.icon.image = UIImage.init(data: imageData)
            }
        }
    }
}
