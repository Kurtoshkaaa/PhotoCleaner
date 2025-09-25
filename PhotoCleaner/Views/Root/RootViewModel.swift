//
//  RootViewModel.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI
import Combine

enum Section: CaseIterable, Hashable {
    case photo,
         swipe,
         settings
    
    var title: String {
        switch self {
        case .photo:
            return "Photos"
        case .swipe:
            return "Swipe"
        case .settings:
            return "Settings"
        }
    }
    
    var isExpanded: Bool {
        switch self {
        case .photo:
            true
        default:
            false
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .photo:
            PhotoLibraryView()
        case .swipe:
            PhotoLibraryView()
        case .settings:
            SettingsView()
        }
    }
}

@MainActor
final class RootViewModel: ObservableObject {
    
    /*
     MARK: - Properties
     */
    
    @Published
    var selectedSection: Section = .photo
    
    /*
     MARK: - Life circle
     */
    
    
    /*
     MARK: - Methods
     */
}
