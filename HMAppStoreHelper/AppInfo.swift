//
//  AppInfo.swift
//  HMAppStoreHelper
//
//  Created by CHM on 2019/5/14.
//  Copyright © 2019 陈晖茂. All rights reserved.
//

import Foundation

private let kFilePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSHomeDirectory()) + "/AppInfoModels"

struct AppInfo: Codable {

    let name: String
    let ID: String
    var imageURL = ""
    var version = ""
    var releaseDate = ""
    
    init(name: String, ID: String) {
        self.name = name
        self.ID = ID
    }
    
    /// 根据dic设置属性
    mutating func setup(appInfoDic: [String: Any]) {
        self.imageURL = (appInfoDic["artworkUrl100"] as? String) ?? ""
        self.version = (appInfoDic["version"] as? String) ?? ""
        
        let releaseDate = (appInfoDic["currentVersionReleaseDate"] as? String) ?? ""
        self.releaseDate = String(releaseDate.prefix(10))
    }
    
    /// 初始化
    static func initizlizeAppInfoModels() -> [AppInfo] {
        var appInfos: [AppInfo]
        let fileURL = URL.init(fileURLWithPath: kFilePath)
        
        if let modelData = try? Data.init(contentsOf: fileURL), let models = try? JSONDecoder().decode([AppInfo].self, from: modelData) {
            appInfos = models

        } else {
            appInfos = [
                AppInfo.init(name: "丰巢管家", ID: "1030700715"),
                AppInfo.init(name: "丰巢", ID: "1259763050"),
                AppInfo.init(name: "丰巢服务站", ID: "1380039025"),
                AppInfo.init(name: "租我家房东", ID: "1228044790"),
                AppInfo.init(name: "租我家", ID: "1198862125"),
                AppInfo.init(name: "日签", ID: "1140397151"),
                AppInfo.init(name: "旅拍", ID: "1001542424"),
            ]
            
            self.save(models: appInfos)
        }
        
        return appInfos
    }
    
    /// 保存到documentDirectory
    static func save(models: [AppInfo]) {
        let fileURL = URL.init(fileURLWithPath: kFilePath)

        if let infoData = try? JSONEncoder().encode(models) {
            try? infoData.write(to: fileURL, options: .atomic)
        }
    }
}
