//
//  SettingsView.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 25.09.25.
//

import SwiftUI
import Lottie

struct SettingsView: View {
    
    /*
     MARK: - Properties
     */
    
    @EnvironmentObject
    private var router: Router
    
    @StateObject
    private var viewModel = SettingsViewModel()
    
    @Environment(\.dismiss)
    private var dismissAction
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24.0.scaled) {
                HStack(spacing: 2.0.scaled) {
                    Text("Settings")
                        .foregroundStyle(.color1)
                        .font(.system(size: 28.0.scaled, weight: .bold))
                        .multilineTextAlignment(.leading)
                    
                    LottieView(animation: .named("Settings"))
                        .playing(loopMode: .loop)
                        .frame(width: 48.0.scaled, height: 48.0.scaled)
                }
                
                /*
                 */
                
                VStack(spacing: 14.0.scaled) {
                    SettingsSectionButton(
                        imageName: "SupportIcon",
                        title: "Support",
                        finishAction: {
                            viewModel.showSupportMail()
                        }
                    )
                    
                    SeparatorView()
                    
                    SettingsSectionButton(
                        imageName: "TermsIcon",
                        title: "Terms of Use",
                        finishAction: {
                            viewModel.openURL(urlString: "https://google.com")
                        }
                    )
                    
                    SeparatorView()
                    
                    SettingsSectionButton(
                        imageName: "PrivacyIcon",
                        title: "Privacy Policy",
                        finishAction: {
                            viewModel.openURL(urlString: "https://google.com")
                        }
                    )
                    
                }
                .padding(16.0.scaled)
                .background(
                    .color16.opacity(0.1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16.0.scaled))
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2.0.scaled) {
                    Text("App version:")
                        .foregroundStyle(.color10)
                        .font(.system(size: 13.0.scaled, weight: .regular))
                    
                    Text(viewModel.applicationVersionTitle)
                        .foregroundStyle(.color1)
                        .font(.system(size: 13.0.scaled, weight: .regular))
                }
            }
            .padding(24.0.scaled)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                LinearGradient(
                    colors: [.color4, .color2],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .loadingOverlay
        }
    }
}

private struct SettingsSectionButton: View {
    
    /*
     MARK: - Properties
     */
    
    var imageName: String
    var title: String
    var finishAction: () -> Void
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        Button(action: finishAction) {
            HStack(spacing: 8.0.scaled) {
                Image(imageName)
                    .resizable()
                    .foregroundStyle(.color1)
                    .frame(width: 24.0.scaled, height: 24.0.scaled)
                
                Text(title)
                    .foregroundStyle(.color1)
                    .font(.system(size: 18.0.scaled, weight: .regular))
                
                Spacer()
                
                Image("ChevronIcon")
                    .resizable()
                    .foregroundStyle(.color1.opacity(0.6))
                    .frame(width: 24.0.scaled, height: 24.0.scaled)
            }
        }
        .buttonStyle(.glass)
    }
}

#Preview {
    SettingsView()
}
