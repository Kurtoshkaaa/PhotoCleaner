//
//  PhotoLibraryView.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 25.09.25.
//


import SwiftUI
import PhotosUI

struct PhotoLibraryView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []
    
    var body: some View {
        VStack {
            PhotosPicker("Выбрать фото", selection: $selectedItems, matching: .images, photoLibrary: .shared())
                .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                images.removeAll()
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
        }
        .padding(24.0.scaled)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            LinearGradient(
                colors: [.color4, .color2],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .loadingOverlay
    }
}
