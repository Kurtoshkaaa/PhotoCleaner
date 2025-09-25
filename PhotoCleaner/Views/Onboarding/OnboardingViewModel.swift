//
//  OnboardingState.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI
import RealmSwift
import Combine
import Photos

enum OnboardingState: Int, CaseIterable {
    case welcome = 1,
         permissions,
         final
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome!"
        case .permissions:
            return "Grant Access"
        case .final:
            return "All Set!"
        }
    }

    var description: String {
        switch self {
        case .welcome:
            return "This app will make your life easier and help you get rid of unnecessary photos so you can feel happier and lighter"
        case .permissions:
            return "We need access to your photo gallery to analyze and organize your pictures. Don’t worry — your privacy is our priority"
        case .final:
            return "Great job! You're ready to start. We hope the app helps you succeed — let’s go inside!"
        }
    }

    var buttonTitle: String {
        switch self {
        case .welcome:
            return "Continue"
        case .permissions:
            return "Allow Access"
        case .final:
            return "Get Started"
        }
    }
    
    var imageName: String {
        switch self {
        case .welcome:
            return "OnboardingImageStep1"
        case .permissions:
            return "OnboardingImageStep2"
        case .final:
            return "OnboardingImageStep3"
        }
    }
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    /*
     MARK: - Properties
     */

    @Published
    var currentPageIndex: Int = 0

    var state: OnboardingState {
        OnboardingState.allCases[currentPageIndex]
    }

    
    /*
     MARK: - Life circle
     */
    

    /*
     MARK: - Methods
     */
    

    func updateState() {
        switch state {
        case .welcome:
            currentPageIndex = 1
        case .permissions:
            requestPhotosAccess()
        case .final:
            try? Settings.current.realm?.safeWrite {
                Settings.current.isOnboardingCompleted = true
            }
        }
    }
    
    func requestPhotosAccess() {
        let current = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch current {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                DispatchQueue.main.async {
                    self?.handlePhotoStatus(newStatus)
                }
            }
        default:
            handlePhotoStatus(current)
        }
    }
    
    private func handlePhotoStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized:
            currentPageIndex += 1
        case .limited:
            currentPageIndex += 1
        case .denied, .restricted:
            openAppSettings()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    private func openAppSettings() {
        guard
            let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
        else { return }
        
        UIApplication.shared.open(url)
    }
}
