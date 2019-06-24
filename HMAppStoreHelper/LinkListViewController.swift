//
//  LinkListViewController.swift
//  HMAppStoreHelper
//
//  Created by 陈晖茂 on 2019/5/14.
//  Copyright © 2019 陈晖茂. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let obtainNewAppID = NSNotification.Name.init("obtainNewAppID")
}

class LinkListViewController: UIViewController {
    
    private let tableView = UITableView.init()
    
    private var appModels = AppInfo.initizlizeAppInfoModels()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Edit", style: .plain, target: self, action: #selector(clickEditBtn))
        self.addTableView()
        
        self.requestAllAppInfo()
        self.delaySaveAppInfos()
        self.addNotification()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }
    
    private func addTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = AppInfoCell.height
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
    }

    private func delaySaveAppInfos() {
        // 可能没有进行编辑操作，15秒后保存一次
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 15, execute: {
            AppInfo.save(models: self.appModels)
        })
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(forName: .obtainNewAppID, object: nil, queue: nil) { (notification) in
            print(notification)
            
            guard let userInfo = notification.userInfo as? [String: String], let ID = userInfo["appID"] else {
                return
            }
            
            self.requestAppInfoWith(ID: ID, success: { [weak self] (appInfoDic) in
                guard let `self` = self else {
                    return
                }
                
                let newAppInfo = AppInfo.init(ID: ID)
                newAppInfo.setup(appInfoDic: appInfoDic)
                self.appModels.append(newAppInfo)
                AppInfo.save(models: self.appModels)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
            
        }
    }
}

//
// MARK: - Event
//
extension LinkListViewController {
    @objc private func clickEditBtn() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: self.tableView.isEditing ? "Done" : "Edit", style: .plain, target: self, action: #selector(clickEditBtn))
    }
    
    @objc private func requestAllAppInfo() {
        for (i, appInfo) in self.appModels.enumerated() {
            
            self.requestAppInfoWith(ID: appInfo.ID) { [weak self] (appInfoDic) in
                self?.appModels[i].setup(appInfoDic: appInfoDic)
                
                DispatchQueue.main.async(execute: {
                    self?.tableView.reloadRows(at: [IndexPath.init(row: i, section: 0)], with: .automatic)
                })
            }
        }
        
    }
    
    private func requestAppInfoWith(ID: String, success: @escaping (_ appInfoDic: [String: Any]) -> Void) {
        guard let url = URL.init(string: "https://itunes.apple.com/cn/lookup?id=" + ID) else {
            return
        }
        
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { (data, _, err) in
            if let error = err {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                return
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data), let jsonDic = jsonObject as? [String: Any] else {
                return
            }
            
            guard let appInfoDic = (jsonDic["results"] as? [[String: Any]])?.first else {
                return
            }
            
            success(appInfoDic)
            
        }.resume()
        
    }
}

//
// MARK: - UITableViewDataSource
//
extension LinkListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AppInfoCell.makeOrReusedCell(inTableView: tableView)
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        cell.setup(appInfo: self.appModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.appModels.remove(at: indexPath.row)
            AppInfo.save(models: self.appModels)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceModel = self.appModels[sourceIndexPath.row]
        self.appModels.remove(at: sourceIndexPath.row)
        self.appModels.insert(sourceModel, at: destinationIndexPath.row)
        AppInfo.save(models: self.appModels)
    }
    
}

//
// MARK: - UITableViewDelegate
//
extension LinkListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itunesPrefix = "https://itunes.apple.com/app/id"
        let itunesLink = itunesPrefix.appending(self.appModels[indexPath.row].ID)
        guard let itunesURL = URL.init(string: itunesLink) else {
            return
        }
        
        //  跳转
        UIApplication.shared.open(itunesURL, options: [:], completionHandler: nil)
        
        //  复制
        UIPasteboard.general.string = itunesLink
        UIPasteboard.general.url = itunesURL
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}
