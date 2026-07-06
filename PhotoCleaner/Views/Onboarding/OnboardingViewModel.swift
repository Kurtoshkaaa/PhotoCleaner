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
            return "Clean Photos Like a Game"
        case .permissions:
            return "Allow Photo Access"
        case .final:
            return "Ready to Swipe"
        }
    }

    var description: String {
        switch self {
        case .welcome:
            return "Swipe right to keep the shots you love and left to mark clutter for deletion."
        case .permissions:
            return "PhotoCleaner needs access to show your library as swipe cards and delete only photos you confirm."
        case .final:
            return "Your gallery is ready. Start a quick swipe session and sort photos in minutes."
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
