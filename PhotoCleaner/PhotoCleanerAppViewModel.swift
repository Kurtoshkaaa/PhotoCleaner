//
//  PhotoCleanerAppViewModel.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI
import RealmSwift
import Combine
internal import Realm

enum PhotoCleanerAppViewModelState {
    case loading,
         onboarding,
         main
}

@MainActor
final class PhotoCleanerAppViewModel: ObservableObject {
    
    /*
     MARK: - Properties
     */
    
    var state: PhotoCleanerAppViewModelState = .loading {
        didSet {
            guard
                state != oldValue
            else { return }
            
            objectWillChange.send()
        }
    }
    
    private var notificationToken: NotificationToken!
    
    /*
     MARK: - Life circle
     */
    
    init() {
        setupObservers()
    }
    
    /*
     MARK: - Methods
     */
    
    private func setupObservers() {
        notificationToken = Settings.current.observe(
            keyPaths: [
                \Settings.isOnboardingCompleted
            ],
            on: .main
        ) { [weak self] change in
            switch change {
            case .change(_, _):
                self?.process()
            case .deleted:
                self?.notificationToken.invalidate()
            case .error(let error):
                print(error)
            }
        }
    }
    
    func process() {
        self.state = Settings.current.isOnboardingCompleted ? .main : .onboarding
    }
}
