//
//  Router.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI
import Combine

final class Router: ObservableObject {
    
    @Published
    var navigationPath = NavigationPath()
}
