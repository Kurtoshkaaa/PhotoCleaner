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
    
    @State
    private var selectedSection: Section = .photo
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            TabView(selection: $selectedSection) {
                Tab("Library", systemImage: "photo.stack", value: Section.photo) {
                    PhotosLibraryView()
                }
                
                Tab("Swipe", systemImage: "hand.draw", value: Section.swipe) {
                    SwipeView()
                }
                
                Tab("Settings", systemImage: "gear", value: Section.settings) {
                    SettingsView()
                }
            }
            .tint(.color1)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .environmentObject(router)
        }
    }
}

#Preview {
    RootView()
}
