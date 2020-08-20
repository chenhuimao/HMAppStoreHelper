//
//  ShareViewController.swift
//  StoreShare
//
//  Created by CHM on 2019/6/22.
//  Copyright © 2019 陈晖茂. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        guard let extensionItems = self.extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }

        for item in extensionItems {
            guard let itemProviders = item.attachments else {
                continue
            }

            let typeIdentifier = kUTTypeURL as String
            for provider in itemProviders where provider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { (url, error) in
                    if let url = url as? URL, let URLScheme = self.getURLSchemeByLink(url) {
                        self.openURL(URLScheme)
                    }
                }
            }
        }
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    //
    // MARK: - custom method
    //
    private func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
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
