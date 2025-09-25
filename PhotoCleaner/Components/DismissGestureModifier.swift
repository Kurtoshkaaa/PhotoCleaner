//
//  DismissGestureModifier.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI

struct DismissGestureModifier: ViewModifier {
    
    /*
     */
    
    @Environment(\.dismiss)
    private var dismiss
    
    /*
     */
    
    func body(content: Content) -> some View {
        content.gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height > 100.0.scaled {
                        dismiss()
                    }
                }
        )
    }
}
