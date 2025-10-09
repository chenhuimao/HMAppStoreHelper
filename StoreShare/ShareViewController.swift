//
//  ShareViewController.swift
//  StoreShare
//
//  Created by CHM on 2019/6/22.
//  Copyright © 2019 陈晖茂. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let extensionItems = self.extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }

        for item in extensionItems {
            guard let itemProviders = item.attachments else {
                continue
            }

            let typeIdentifier = UTType.url.identifier
            for provider in itemProviders where provider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { (url, error) in
                    if let url = url as? URL, let URLScheme = self.getURLSchemeByLink(url) {
                        self.openURL(URLScheme)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    //
    // MARK: - custom method
    //
    private func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:], completionHandler: nil)
                break;
            }
            responder = responder?.next
        }
    }

    private func getURLSchemeByLink(_ url: URL) -> URL? {
        guard url.host?.contains("apple.com") ?? false else {
            return nil
        }
        
        let appStoreHelperSchems = "HMAppStoreHelper://"
        for pathComponent in url.pathComponents {
            if pathComponent.hasPrefix("id") {
                return URL.init(string: appStoreHelperSchems + pathComponent)
            }
        }
        
        return nil
    }
}
