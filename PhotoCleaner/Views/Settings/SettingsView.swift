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
    
    @StateObject
    private var viewModel = SettingsViewModel()
    
    @AppStorage("photoCleanerAskBeforeDeletingMarkedPhotos")
    private var askBeforeDeletingMarkedPhotos: Bool = true
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24.0.scaled) {
                    headerView
                    
                    SettingsGlassGroup {
                        SettingsActionRow(
                            icon: .asset("SupportIcon"),
                            title: "Support",
                            action: {
                                viewModel.showSupportMail()
                            }
                        )
                        
                        SettingsDivider()
                        
                        ShareLink(item: viewModel.shareTitle) {
                            SettingsRowContent(
                                icon: .asset("ShareIcon"),
                                title: "Share the app",
                                trailingTitle: nil,
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    SettingsGlassGroup {
                        SettingsActionRow(
                            icon: .system("photo.stack.fill"),
                            title: "Photo Access",
                            trailingTitle: viewModel.photoAccessTitle,
                            action: {
                                viewModel.openApplicationSettings()
                            }
                        )
                        
                        SettingsDivider()
                        
                        SettingsToggleRow(
                            icon: .system("trash.slash.fill"),
                            title: "Confirm Delete",
                            isOn: $askBeforeDeletingMarkedPhotos
                        )
                    }
                    
                    SettingsGlassGroup {
                        SettingsActionRow(
                            icon: .asset("TermsIcon"),
                            title: "Terms of Use",
                            action: {
                                viewModel.openURL(urlString: "https://google.com")
                            }
                        )
                        
                        SettingsDivider()
                        
                        SettingsActionRow(
                            icon: .asset("PrivacyIcon"),
                            title: "Privacy Policy",
                            action: {
                                viewModel.openURL(urlString: "https://google.com")
                            }
                        )
                    }
                    
                    SettingsGlassGroup {
                        SettingsRowContent(
                            icon: .system("info.circle.fill"),
                            title: "App Version",
                            trailingTitle: viewModel.applicationVersionTitle,
                            showsChevron: false
                        )
                    }
                }
                .padding(.top, 8.0.scaled)
                .padding(.bottom, 34.0.scaled)
                .padding(.horizontal, 24.0.scaled)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                LinearGradient(
                    colors: [
                        .color4.opacity(0.78),
                        .color2
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .onAppear {
                viewModel.setupPhotoAccessTitle()
            }
            .loadingOverlay
        }
    }
    
    /*
     MARK: - Private views
    */
    
    private var headerView: some View {
        HStack(spacing: 2.0.scaled) {
            Text("Settings")
                .foregroundStyle(.color1)
                .font(.system(size: 28.0.scaled, weight: .bold))
                .multilineTextAlignment(.center)
            
            LottieView(animation: .named("Settings"))
                .playing(loopMode: .loop)
                .valueProvider(
                    ColorValueProvider(LottieColor(r: 1.0, g: 1.0, b: 1.0, a: 1.0)),
                    for: AnimationKeypath(keypath: "**.Fill 1.Color")
                )
                .valueProvider(
                    ColorValueProvider(LottieColor(r: 1.0, g: 1.0, b: 1.0, a: 1.0)),
                    for: AnimationKeypath(keypath: "**.Stroke.Color")
                )
                .frame(width: 48.0.scaled, height: 48.0.scaled)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct SettingsGlassGroup<Content: View>: View {
    
    /*
     MARK: - Properties
     */
    
    @ViewBuilder
    var content: Content
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        VStack(spacing: 0.0) {
            content
        }
        .padding(.horizontal, 20.0.scaled)
        .background(.color1.opacity(0.04))
        .settingsGlassSurface(cornerRadius: CGFloat(16.0.scaled))
        .clipShape(RoundedRectangle(cornerRadius: 16.0.scaled))
    }
}

private struct SettingsActionRow: View {
    
    /*
     MARK: - Properties
     */
    
    var icon: SettingsRowIcon
    var title: String
    var trailingTitle: String?
    var action: () -> Void
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        Button(action: action) {
            SettingsRowContent(
                icon: icon,
                title: title,
                trailingTitle: trailingTitle,
                showsChevron: true
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsToggleRow: View {
    
    /*
     MARK: - Properties
     */
    
    var icon: SettingsRowIcon
    var title: String
    
    @Binding
    var isOn: Bool
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        HStack(spacing: 8.0.scaled) {
            SettingsRowIconView(icon: icon)
            
            Text(title)
                .foregroundStyle(.color1)
                .font(.system(size: 17.0.scaled, weight: .regular))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.color4)
        }
        .frame(height: 52.0.scaled)
        .contentShape(Rectangle())
    }
}

private struct SettingsRowContent: View {
    
    /*
     MARK: - Properties
     */
    
    var icon: SettingsRowIcon
    var title: String
    var trailingTitle: String?
    var showsChevron: Bool
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        HStack(spacing: 8.0.scaled) {
            SettingsRowIconView(icon: icon)
            
            Text(title)
                .foregroundStyle(.color1)
                .font(.system(size: 17.0.scaled, weight: .regular))
            
            Spacer(minLength: 12.0.scaled)
            
            if let trailingTitle {
                Text(trailingTitle)
                    .foregroundStyle(.color1.opacity(0.58))
                    .font(.system(size: 13.0.scaled, weight: .medium))
                    .lineLimit(1)
            }
            
            if showsChevron {
                Image("ChevronIcon")
                    .resizable()
                    .foregroundStyle(.color1.opacity(0.45))
                    .frame(width: 24.0.scaled, height: 24.0.scaled)
            }
        }
        .frame(height: 52.0.scaled)
        .contentShape(Rectangle())
    }
}

private struct SettingsRowIconView: View {
    
    /*
     MARK: - Properties
     */
    
    var icon: SettingsRowIcon
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        switch icon {
        case .asset(let name):
            Image(name)
                .resizable()
                .foregroundStyle(.color1)
                .frame(width: 24.0.scaled, height: 24.0.scaled)
        case .system(let name):
            Image(systemName: name)
                .foregroundStyle(.color1)
                .font(.system(size: 20.0.scaled, weight: .semibold))
                .frame(width: 24.0.scaled, height: 24.0.scaled)
        }
    }
}

private struct SettingsDivider: View {
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        Rectangle()
            .fill(.color1.opacity(0.1))
            .frame(height: 1.0.scaled)
    }
}

private enum SettingsRowIcon {
    case asset(String),
         system(String)
}

private struct SettingsGlassSurface: ViewModifier {
    
    /*
     MARK: - Properties
     */
    
    var cornerRadius: CGFloat
    
    /*
     MARK: - Body
     */
    
    func body(
        content: Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(
                    .regular.tint(.color1.opacity(0.05)),
                    in: .rect(cornerRadius: cornerRadius)
                )
        } else {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: cornerRadius)
                )
        }
    }
}

private extension View {
    
    func settingsGlassSurface(
        cornerRadius: CGFloat
    ) -> some View {
        modifier(SettingsGlassSurface(cornerRadius: cornerRadius))
    }
}

#Preview {
    SettingsView()
}
