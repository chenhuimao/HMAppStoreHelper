//
//  LinkListViewController.swift
//  HMAppStoreHelper
//
//  Created by 陈晖茂 on 2019/5/14.
//  Copyright © 2019 陈晖茂. All rights reserved.
//

import UIKit

class LinkListViewController: UIViewController {
    
    private let tableView = UITableView.init()
    
    private var appTuples: [(name: String, ID: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeData()
        self.addTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }
    
    private func initializeData() {
        self.appTuples.append((name: "丰巢管家", ID: "1030700715"))
        self.appTuples.append((name: "丰巢", ID: "1259763050"))
        self.appTuples.append((name: "丰巢服务站", ID: "1380039025"))
        self.appTuples.append((name: "租我家房东", ID: "1228044790"))
        self.appTuples.append((name: "租我家", ID: "1198862125"))
        self.appTuples.append((name: "日签", ID: "1140397151"))
        self.appTuples.append((name: "旅拍", ID: "1001542424"))
    }
    
    private func addTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 60
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
    }

}

//
// MARK: - UITableViewDataSource, UITableViewDelegate
//
extension LinkListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appTuples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "LinkListCell";
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        if indexPath.row % 2 == 0 {
            cell?.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        } else {
            cell?.contentView.backgroundColor = UIColor.white
        }
        cell?.textLabel?.text = self.appTuples[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itunesPrefix = "https://itunes.apple.com/app/id"
        let itunesLink = itunesPrefix.appending(self.appTuples[indexPath.row].ID)
        guard let itunesURL = URL.init(string: itunesLink) else {
            return
        }
        
        //  跳转
        UIApplication.shared.open(itunesURL, options: [:], completionHandler: nil)
        
        //  复制
        UIPasteboard.general.string = itunesLink
        UIPasteboard.general.url = itunesURL
    }
    
}
