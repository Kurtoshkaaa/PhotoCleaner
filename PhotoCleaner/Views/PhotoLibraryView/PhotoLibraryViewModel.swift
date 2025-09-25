//
//  PhotoLibraryViewModel.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 25.09.25.
//


import SwiftUI
import Photos
import Combine

class PhotoLibraryViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    
    init() {
        loadPhotos()
    }
    
    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let manager = PHCachingImageManager()
        let targetSize = CGSize(width: 200, height: 200)
        
        assets.enumerateObjects { asset, _, _ in
            manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { image, _ in
                if let img = image {
                    DispatchQueue.main.async {
                        self.images.append(img)
                    }
                }
            }
        }
    }
}

struct PhotoLibraryView2: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(viewModel.images, id: \.self) { img in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(8)
                }
            }
        }
    }
}
