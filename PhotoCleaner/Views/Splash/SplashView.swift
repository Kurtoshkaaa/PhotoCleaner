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
        Image("SplashBackground")
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
