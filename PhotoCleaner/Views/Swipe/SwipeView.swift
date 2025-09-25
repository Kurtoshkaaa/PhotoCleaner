//
//  SwipeView.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 25.09.25.
//

import SwiftUI
import Lottie

struct SwipeView: View {
    
    /*
     MARK: - Properties
     */
    
    @Environment(\.dismiss)
    private var dismissAction
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        VStack(spacing: 24.0.scaled) {
            HStack(spacing: 2.0.scaled) {
                Text("Swipe")
                    .foregroundStyle(.color1)
                    .font(.system(size: 28.0.scaled, weight: .bold))
                    .multilineTextAlignment(.leading)
                
                LottieView(animation: .named("Swipe"))
                    .playing(loopMode: .loop)
                    .frame(width: 48.0.scaled, height: 48.0.scaled)
            }
        }
        .padding(.bottom, 16.0.scaled)
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
        HStack(spacing: 8.0.scaled) {
            Image(imageName)
                .resizable()
                .foregroundStyle(.color1)
                .frame(width: 24.0.scaled, height: 24.0.scaled)
            
            Text(title)
                .foregroundStyle(.color1)
            
            Spacer()
            
            Image("ChevronIcon")
                .resizable()
                .foregroundStyle(.color1.opacity(0.6))
                .frame(width: 24.0.scaled, height: 24.0.scaled)
        }
        .onTapGesture {
            finishAction()
        }
    }
}

#Preview {
    SwipeView()
}
