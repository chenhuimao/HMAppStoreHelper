//
//  AppInfo.swift
//  HMAppStoreHelper
//
//  Created by CHM on 2019/5/14.
//  Copyright © 2019 陈晖茂. All rights reserved.
//

import Foundation

private let kFilePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSHomeDirectory()) + "/AppInfoModels"

private let kIDFilePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSHomeDirectory()) + "/AppInfoIDs"

/// APP信息模型
class AppInfo: Codable {

    let ID: String
    var name = ""
    var imageURL = ""
    var version = ""
    var releaseDate = ""
    /// 当前版本评分
    var averageRating = 0.0
    /// 当前版本已评分的用户数量
    var userRatingCount = 0
    /// 价格
    var price = 0.00
    
    /// 是否更新了版本
    var isUpdated = false
    /// 是否更新了价格
    var isUpdatePrice = false
    
    init(ID: String) {
        self.ID = ID
    }
    
    /// 根据dic设置属性
    func setup(appInfoDic: [String: Any]) {
        self.name = (appInfoDic["trackName"] as? String) ?? ""
        
        self.imageURL = (appInfoDic["artworkUrl100"] as? String) ?? ""
        
        let version = (appInfoDic["version"] as? String) ?? ""
        self.isUpdated = (self.version.count > 0 && self.version != version)
        self.version = version
        
        let releaseDate = (appInfoDic["currentVersionReleaseDate"] as? String) ?? ""
        self.releaseDate = String(releaseDate.prefix(10))
        
        self.averageRating = (appInfoDic["averageUserRatingForCurrentVersion"] as? Double) ?? 0.0
        self.userRatingCount = (appInfoDic["userRatingCountForCurrentVersion"] as? Int) ?? 0
        
        let price = (appInfoDic["price"] as? Double) ?? 0.00
        self.isUpdatePrice = (self.price > 0 && self.price != price)
        self.price = price
    }
    
    /// 初始化
    static func initizlizeAppInfoModels() -> [AppInfo] {
        var appInfos: [AppInfo]
        let fileURL = URL.init(fileURLWithPath: kFilePath)
        let IDFileURL = URL.init(fileURLWithPath: kIDFilePath)
        
        if let modelData = try? Data.init(contentsOf: fileURL), let models = try? JSONDecoder().decode([AppInfo].self, from: modelData) {
            appInfos = models

        } else if let IDData = try? Data.init(contentsOf: IDFileURL), let IDs = try? JSONDecoder().decode([String].self, from: IDData) {
            appInfos = [AppInfo]()
            for ID in IDs {
                appInfos.append(AppInfo.init(ID: ID))
            }
            
        } else {
            appInfos = [
                AppInfo.init(ID: "1030700715"),     //  丰巢管家
                AppInfo.init(ID: "1259763050"),     //  丰巢
                AppInfo.init(ID: "1380039025"),     //  丰巢服务站
                AppInfo.init(ID: "1228044790"),     //  租我家房东
                AppInfo.init(ID: "1198862125"),     //  租我家
                AppInfo.init(ID: "1140397151"),     //  日签
                AppInfo.init(ID: "1001542424"),     //  旅拍
            ]
            
        }
        
        //  重置部分属性
        for appInfo in appInfos {
            appInfo.isUpdated = false
            appInfo.isUpdatePrice = false
        }
        
        return appInfos
    }
    
    /// 保存到documentDirectory
    static func save(models: [AppInfo]) {
        //  保存模型
        let fileURL = URL.init(fileURLWithPath: kFilePath)

        if let infoData = try? JSONEncoder().encode(models) {
            try? infoData.write(to: fileURL, options: .atomic)
        }
        
        //  保存ID
        let IDs = models.map { $0.ID }
        let idFileURL = URL.init(fileURLWithPath: kIDFilePath)
        
        if let IDData = try? JSONEncoder().encode(IDs) {
            try? IDData.write(to: idFileURL, options: .atomic)
        }
    }
    
    /// models数组是否已经存在某个ID
    static func isExist(ID: String, models: [AppInfo]) -> Bool {
        for model in models where model.ID == ID {
            return true
        }
        return false
    }
}
