//
//  LinkListViewController.swift
//  HMAppStoreHelper
//
//  Created by 陈晖茂 on 2019/5/14.
//  Copyright © 2019 陈晖茂. All rights reserved.
//

import UIKit
import SVProgressHUD

extension NSNotification.Name {
    static let obtainNewAppID = NSNotification.Name.init("obtainNewAppID")
}

class LinkListViewController: UIViewController {
    
    private let tableView = UITableView.init()
    
    private var appModels = AppInfo.initizlizeAppInfoModels()
    
    private var observer: NSObjectProtocol?
    
    deinit {
        NotificationCenter.default.removeObserver(self.observer as Any)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Refresh", style: .plain, target: self, action: #selector(requestAllAppInfo))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Edit", style: .plain, target: self, action: #selector(clickEditBtn))
        self.addTableView()
        self.requestAllAppInfo()
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
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
    }
    
    private func addNotification() {
        self.observer = NotificationCenter.default.addObserver(forName: .obtainNewAppID, object: nil, queue: nil) { [weak self] (notification) in
            
            guard let `self` = self else {
                return
            }
            
            guard let userInfo = notification.userInfo as? [String: String], let ID = userInfo["appID"] else {
                return
            }
            
            let isExistTuple = AppInfo.isExist(ID: ID, models: self.appModels)
            if isExistTuple.isExist {
                self.tableView.scrollToRow(at: IndexPath(row: isExistTuple.index, section: 0), at: .middle, animated: true)
                return
            }
            
            self.requestAppInfoWith(ID: ID, isCN: true, success: { [weak self] (appInfoDic) in
                guard let `self` = self else {
                    return
                }
                
                let newAppInfo = AppInfo.init(ID: ID)
                newAppInfo.setup(appInfoDic: appInfoDic)
                self.appModels.append(newAppInfo)
                self.saveAppInfoModel()
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: self.appModels.count - 1, section: 0), at: .middle, animated: true)
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
    
    // 请求更新数据并刷新列表
    @objc private func requestAllAppInfo() {
        for (i, appInfo) in self.appModels.enumerated() {
            
            self.requestAppInfoWith(ID: appInfo.ID, isCN: true) { [weak self] (appInfoDic) in
                
                guard let `self` = self else {
                    return
                }
                
                self.appModels[i].setup(appInfoDic: appInfoDic)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadRows(at: [IndexPath.init(row: i, section: 0)], with: .automatic)
                    
                    self.classForCoder.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.saveAppInfoModel), object: nil)
                    self.perform(#selector(self.saveAppInfoModel), with: nil, afterDelay: 3)
                })
            }
        }
        
    }
    
    /// 优先请求国区信息，失败则使用美区
    private func requestAppInfoWith(ID: String, isCN: Bool, success: @escaping (_ appInfoDic: [String: Any]) -> Void) {
        let urlString = isCN ? ("https://itunes.apple.com/cn/lookup?id=" + ID) : ("https://itunes.apple.com/lookup?id=" + ID)
        guard let url = URL.init(string: urlString) else {
            return
        }
        
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { (data, _, err) in
            if let error = err {
                print(error.localizedDescription)
                if (isCN) {
                    self.requestAppInfoWith(ID: ID, isCN: false, success: success)
                }
                return
            }
            
            guard let data = data else {
                if (isCN) {
                    self.requestAppInfoWith(ID: ID, isCN: false, success: success)
                }
                return
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data), let jsonDic = jsonObject as? [String: Any] else {
                if (isCN) {
                    self.requestAppInfoWith(ID: ID, isCN: false, success: success)
                }
                return
            }
            
            guard let appInfoDic = (jsonDic["results"] as? [[String: Any]])?.first else {
                if (isCN) {
                    self.requestAppInfoWith(ID: ID, isCN: false, success: success)
                } else {
                    let isExistTuple = AppInfo.isExist(ID: ID, models: self.appModels)
                    if isExistTuple.isExist {
                        let appInfo = self.appModels[isExistTuple.index]
                        self.show(status: "\(appInfo.name)已下架")
                    } else {
                        self.show(status: "App(id\(ID))已下架")
                    }
                }
                return
            }
            
            if (!isCN) {
                print("美区App(id\(ID))")
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
        cell.setup(appInfo: self.appModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.appModels.remove(at: indexPath.row)
            self.saveAppInfoModel()
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
        self.saveAppInfoModel()
    }
    
}

//
// MARK: - UITableViewDelegate
//
extension LinkListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itunesPrefix = "https://itunes.apple.com/app/id"
        let appModel = self.appModels[indexPath.row]
        let itunesLink = itunesPrefix.appending(appModel.ID)
        guard let itunesURL = URL.init(string: itunesLink) else {
            return
        }
        
        print("App Name:\(appModel.name), App id:\(appModel.ID)")
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

//
// MARK: - Helper
//
extension LinkListViewController {

    @objc private func saveAppInfoModel() {
        AppInfo.save(models: self.appModels)
    }
    
    private func show(status: String) {
        if (Thread.isMainThread) {
            SVProgressHUD.showInfo(withStatus: status)
            SVProgressHUD.dismiss(withDelay: 5)
        } else {
            DispatchQueue.main.async {
                SVProgressHUD.showInfo(withStatus: status)
                SVProgressHUD.dismiss(withDelay: 5)
            }
        }
    }
}
