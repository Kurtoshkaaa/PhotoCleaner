//
//  LoaderViewModifier.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI
import Lottie

private struct LoaderViewModifier: ViewModifier {
    
    @State
    private var isUpdating: Bool = false

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: StartUpdating)) { _ in
                isUpdating = true
            }
            .onReceive(NotificationCenter.default.publisher(for: FinishUpdating)) { _ in
                isUpdating = false
            }
            .overlay(
                Group {
                    if isUpdating {
                        Rectangle()
                            .fill(.color2.opacity(0.7))
                            .ignoresSafeArea()
                            .transition(.opacity)
                    }
                }
            )
            .overlay(
                Group {
                    if isUpdating {
                        LottieView(animation:.named("Loader"))
                            .playing(loopMode: .loop)
                        .frame(
                            width: 80.0.scaled,
                            height: 80.0.scaled
                        )
                        .transition(.opacity)
                    }
                }
            )
            .animation(.easeInOut(duration: 0.3), value: isUpdating)
    }
}

extension View {
    var loadingOverlay: some View {
        self.modifier(LoaderViewModifier())
    }
}
