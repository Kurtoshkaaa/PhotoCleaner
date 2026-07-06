//
//  SplashView.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI

struct SplashView: View {
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        ZStack {
            Image("SplashBackground")
                .resizable()
                .ignoresSafeArea()

            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 220.0.scaled, height: 220.0.scaled)
        }
    }
}

#Preview {
    SplashView()
}
