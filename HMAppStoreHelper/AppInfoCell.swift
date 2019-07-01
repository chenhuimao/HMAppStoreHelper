//
//  AppInfoCell.swift
//  HMAppStoreHelper
//
//  Created by CHM on 2019/5/17.
//  Copyright © 2019 陈晖茂. All rights reserved.
//

import UIKit
import Kingfisher

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
        return 84
    }
    
    func setup(appInfo: AppInfo) {
        self.appInfo = appInfo

        self.contentView.isHidden = appInfo.name.count == 0
        
        self.requestIconImage()
        self.nameLab.text = appInfo.name
        self.versionLab.text = appInfo.version
        self.dateLab.text = appInfo.releaseDate
        self.ratingLab.text = String.init(format: "⭐️%.1lf(%zd)", appInfo.averageRating, appInfo.userRatingCount)
        
        self.priceLab.text = String.init(format: "¥%.2lf", appInfo.price)
        self.priceLab.isHidden = appInfo.price <= 0
        
        if appInfo.isUpdated {
            self.versionLab.textColor = .red
            self.dateLab.textColor = .red
        } else {
            self.versionLab.textColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            self.dateLab.textColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }
        
        self.priceLab.textColor = appInfo.isUpdatePrice ? .red : .init(red: 0.04, green: 0.37, blue: 1.0, alpha: 1)
        
        self.setNeedsLayout()
    }
}

class AppInfoCell: UITableViewCell {
    
    private var appInfo: AppInfo?
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        icon.layer.cornerRadius = 16
        icon.layer.masksToBounds = true
        icon.layer.borderColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        icon.layer.borderWidth = 1 / UIScreen.main.scale
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
        lab.font = UIFont.systemFont(ofSize: 14)
        return lab
    }()
    
    private let dateLab: UILabel = {
        let lab = UILabel()
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
    
    private let priceLab: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = UIColor.init(red: 0.93, green: 0.93, blue: 0.96, alpha: 1)
        lab.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lab.textAlignment = .center
        lab.layer.masksToBounds = true
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
        self.contentView.addSubview(self.priceLab)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let marginX: CGFloat = 10
        let marginY: CGFloat = 5
        let iconSidelength: CGFloat = 64
        self.icon.frame = CGRect.init(x: marginX, y: (self.contentView.bounds.height - iconSidelength) / 2, width: iconSidelength, height: iconSidelength)
        
        let nameLabX = self.icon.frame.maxX + marginX
        let nameLabWidth = self.contentView.bounds.width - nameLabX - marginX
        self.nameLab.frame = CGRect.init(x: nameLabX, y: 10, width: nameLabWidth, height: self.nameLab.intrinsicContentSize.height)
        
        self.versionLab.frame = CGRect.init(x: self.nameLab.frame.minX, y: self.nameLab.frame.maxY + marginY, width: self.versionLab.intrinsicContentSize.width, height: self.versionLab.intrinsicContentSize.height)
        self.dateLab.frame = CGRect.init(x: self.versionLab.frame.maxX + marginX, y: self.versionLab.frame.minY, width: self.dateLab.intrinsicContentSize.width, height: self.dateLab.intrinsicContentSize.height)
        
        self.ratingLab.frame = CGRect.init(x: self.versionLab.frame.minX, y: self.versionLab.frame.maxY + marginY, width: self.ratingLab.intrinsicContentSize.width, height: self.ratingLab.intrinsicContentSize.height)
        
        let priceLabHeight: CGFloat = 26
        let priceLabWidth: CGFloat = self.priceLab.intrinsicContentSize.width + 24
        self.priceLab.layer.cornerRadius = priceLabHeight / 2
        self.priceLab.frame = CGRect.init(x: self.contentView.bounds.width - marginX - priceLabWidth, y: (self.contentView.bounds.height - priceLabHeight) / 2, width: priceLabWidth, height: priceLabHeight)
    }
    
    private func requestIconImage() {
        self.icon.kf.cancelDownloadTask()
        self.icon.kf.setImage(with: URL.init(string: self.appInfo?.imageURL ?? ""), placeholder: nil)
    }
}
