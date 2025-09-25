//
//  PhotosLibraryView.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 25.09.25.
//


import SwiftUI
import PhotosUI
import Lottie

struct PhotosLibraryView: View {
    
    @State
    private var selectedItems: [PhotosPickerItem] = []
    @State
    private var images: [UIImage] = []
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        VStack(spacing: 24.0) {
            HStack(spacing: 2.0.scaled) {
                Text("Photos")
                    .foregroundStyle(.color1)
                    .font(.system(size: 28.0.scaled, weight: .bold))
                    .multilineTextAlignment(.leading)
                
                LottieView(animation: .named("Photos"))
                    .playing(loopMode: .loop)
                    .frame(width: 32.0.scaled, height: 32.0.scaled)
            }
            
            PhotosPicker("Select photo", selection: $selectedItems, matching: .images, photoLibrary: .shared())
                .padding()
            
            ScrollView(showsIndicators: false) {
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
