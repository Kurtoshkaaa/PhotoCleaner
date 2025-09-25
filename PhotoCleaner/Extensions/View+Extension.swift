//
//  View+Extension.swift
//  FreePlay
//
//  Created by Alexey Kurto on 15.04.25.
//

import UIKit
import SwiftUI

extension View {

    /*
     */
    
    var dismissGesture: some View {
        self.modifier(DismissGestureModifier())
    }
    
    var shadow: some View {
        self.shadow(
            color: .color4.opacity(0.05),
            radius: 16.0.scaled,
            x: 0,
            y: 0
        )
    }
    
    /*
     */

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
}
