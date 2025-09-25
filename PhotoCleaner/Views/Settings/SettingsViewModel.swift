//
//  SettingsViewModel.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 25.09.25.
//

import SwiftUI
import MessageUI
import DeviceKit
import Combine

final class SettingsViewModel: NSObject, ObservableObject {
    
    /*
     MARK: - Properties
     */
    
    @Published
    var applicationVersionTitle: String = ""
    
    /*
     MARK: - Methods
     */

    /*
     MARK: - Life circle
     */
    
    override init() {
        super.init()
        
        setupApplicationVersionTitle()
    }
    
    /*
     MARK: - Methods
     */
    
    func setupApplicationVersionTitle() {
        guard
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        else { return }
        
        let title = String(
            format: "%@ (%@)",
            version,
            buildNumber
        )
        
        applicationVersionTitle = title
    }
    
    func openURL(urlString: String) {
        guard
            let url = URL(string: urlString)
        else { return }
        
        UIApplication.shared.open(url)
    }
    
    func showSupportMail() {
        guard
            MFMailComposeViewController.canSendMail(),
            let presenter = UIApplication.shared.topViewController
        else { return }

        let recipientEmail: String = "kurtoshka1993@gmail.com"
        let subject: String = "Support request"
        var body: String = "\n\n"
        
        if
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        {
            body += "App version: " + version + " (\(build))" + "\n"
        }
        
        body += DeviceKit.Device.current.description + ", " + UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([recipientEmail])
        mailViewController.setSubject(subject)
        mailViewController.setMessageBody(body, isHTML: false)
        
        presenter.present(
            mailViewController,
            animated: true
        )
    }
}

/*
 MARK: - Extension
 */

extension SettingsViewModel: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(
            animated: true,
            completion: nil
        )
    }
}
