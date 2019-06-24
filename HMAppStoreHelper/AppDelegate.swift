//
//  AppDelegate.swift
//  HMAppStoreHelper
//
//  Created by CHM on 2019/5/14.
//  Copyright © 2019 pal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        print(url)    HMAppStoreHelper://id382201985
        
        if let host = url.host, host.contains("id") {
            let appID = host.replacingOccurrences(of: "id", with: "")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { //  需要等待LinkListVC监听之后
                NotificationCenter.default.post(name: .obtainNewAppID, object: nil, userInfo: ["appID": appID])
            }
        }
        
        return true
    }

}
