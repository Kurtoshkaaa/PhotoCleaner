//
//  RootView.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI

struct RootView: View {
    
    /*
     MARK: - Properties
     */
    
    @StateObject
    private var viewModel = RootViewModel()
    
    @StateObject
    private var router = Router()
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            TabView {
                Tab("Photos", systemImage: "photo.stack") {
                    PhotosLibraryView()
                }
                
                Tab("Swipe", systemImage: "hand.draw") {
                    SwipeView()
                }
                
                Tab("Settings", systemImage: "gear") {
                    SettingsView()
                }
            }
            .tint(.color1)
            .padding(.bottom, 32.0.scaled)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .ignoresSafeArea()
            .environmentObject(router)
        }
    }
}

#Preview {
    RootView()
}
