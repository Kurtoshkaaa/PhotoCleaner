//
//  PhotoCleanerApp.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI
import AppTrackingTransparency

@main
struct PhotoCleanerApp: App {
    
    /*
     MARK: -
     */
    
    @StateObject
    private var viewModel = PhotoCleanerAppViewModel()
    
    /*
     MARK: -
     */
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch viewModel.state {
                case .loading:
                    SplashView()
                        .onAppear{
                            viewModel.process()
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                ATTrackingManager.requestTrackingAuthorization { _ in
                                    
                                }
                            }
                        }
                case .onboarding:
                    OnboardingView()
                case .main:
                    RootView()
                        .environmentObject(viewModel)
                }
            }
            .animation(
                .easeInOut(duration: 0.2),
                value: viewModel.state
            )
        }
    }
}
