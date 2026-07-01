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
import Photos

final class SettingsViewModel: NSObject, ObservableObject {
    
    /*
     MARK: - Properties
     */
    
    @Published
    var applicationVersionTitle: String = ""
    
    @Published
    var photoAccessTitle: String = ""
    
    var shareTitle: String {
        guard
            !AppID.isEmpty
        else { return "Try PhotoCleaner" }
        
        return "Try PhotoCleaner: https://apps.apple.com/app/id\(AppID)"
    }
    
    /*
     MARK: - Methods
     */

    /*
     MARK: - Life circle
     */
    
    override init() {
        super.init()
        
        setupApplicationVersionTitle()
        setupPhotoAccessTitle()
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
    
    func setupPhotoAccessTitle() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            photoAccessTitle = "Full Access"
        case .limited:
            photoAccessTitle = "Limited Access"
        case .denied, .restricted:
            photoAccessTitle = "No Access"
        case .notDetermined:
            photoAccessTitle = "Not Asked"
        @unknown default:
            photoAccessTitle = "Unknown"
        }
    }
    
    func openURL(urlString: String) {
        guard
            let url = URL(string: urlString)
        else { return }
        
        UIApplication.shared.open(url)
    }
    
    func openApplicationSettings() {
        openURL(urlString: UIApplication.openSettingsURLString)
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
