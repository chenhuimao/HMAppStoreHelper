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
    
    private var appModels = AppInfo.initizlizeAppInfoModels()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
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
// MARK: - UITableViewDataSource
//
extension LinkListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "LinkListCell";
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        if indexPath.row % 2 == 0 {
            cell?.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        } else {
            cell?.backgroundColor = UIColor.white
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = self.appModels[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.appModels.remove(at: indexPath.row)
            AppInfo.save(models: self.appModels)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.perform(#selector(UITableView.reloadData), with: nil, afterDelay: 1.0)
        }
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
