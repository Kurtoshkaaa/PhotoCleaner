//
//  PhotoCleanerBackground.swift
//  PhotoCleaner
//
//  Created by Codex on 06.07.26.
//

import SwiftUI

enum PhotoCleanerStyle {
    
    static let keepAccent = Color(red: 0.56, green: 0.32, blue: 1.0)
    static let deleteAccent = Color(red: 1.0, green: 0.29, blue: 0.43)
    static let sparkleAccent = Color(red: 1.0, green: 0.78, blue: 0.22)
}

struct PhotoCleanerBackground: View {
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        ZStack {
            Image("SplashBackground")
                .resizable()
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    .color2.opacity(0.04),
                    .color2.opacity(0.42)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

struct PhotoCleanerStateCard: View {
    
    /*
     MARK: - Properties
     */
    
    var imageName: String?
    var systemImage: String?
    var title: String
    var message: String
    var buttonTitle: String?
    var accent: Color
    var action: (() -> Void)?
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        VStack(spacing: 16.0.scaled) {
            iconView
            
            VStack(spacing: 8.0.scaled) {
                Text(title)
                    .foregroundStyle(.color1)
                    .font(.system(size: 22.0.scaled, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .foregroundStyle(.color1.opacity(0.72))
                    .font(.system(size: 15.0.scaled, weight: .regular))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if
                let buttonTitle,
                let action
            {
                Button(buttonTitle, action: action)
                    .font(.system(size: 17.0.scaled, weight: .semibold))
                    .foregroundStyle(.color1)
                    .frame(height: 52.0.scaled)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.glass)
                    .padding(.top, 4.0.scaled)
            }
        }
        .padding(24.0.scaled)
        .frame(maxWidth: .infinity)
        .background(.color1.opacity(0.06))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24.0.scaled))
        .overlay {
            RoundedRectangle(cornerRadius: 24.0.scaled)
                .stroke(.color1.opacity(0.12), lineWidth: 1.0.scaled)
        }
    }
    
    /*
     MARK: - Private views
     */
    
    @ViewBuilder
    private var iconView: some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 116.0.scaled, height: 116.0.scaled)
        } else if let systemImage {
            Image(systemName: systemImage)
                .foregroundStyle(accent)
                .font(.system(size: 52.0.scaled, weight: .semibold))
                .frame(width: 84.0.scaled, height: 84.0.scaled)
                .background(accent.opacity(0.16), in: Circle())
        }
    }
}
