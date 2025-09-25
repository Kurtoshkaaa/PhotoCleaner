//
//  SeparatorView.swift
//  FreePlay
//
//  Created by Ne Spesha on 10/04/2025.
//

import SwiftUI

struct SeparatorView: View {
    
    @State
    var color: Color = .color3
    
    var body: some View {
        Rectangle()
            .fill(color.opacity(0.2))
            .frame(maxWidth: .infinity)
            .frame(height: 1.0.scaled)
    }
    
}
