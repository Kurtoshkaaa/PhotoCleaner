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

    /*
     MARK: - Properties
     */
    
    @StateObject
    private var viewModel = PhotosLibraryViewModel()

    /*
     MARK: - Body
     */
    
    var body: some View {
        VStack(spacing: 8.0) {
            HStack(spacing: 2.0.scaled) {
                Text("Photos")
                    .foregroundStyle(.color1)
                    .font(.system(size: 28.0.scaled, weight: .bold))
                
                LottieView(animation: .named("Photos"))
                    .playing(loopMode: .loop)
                    .frame(width: 32.0.scaled, height: 32.0.scaled)
            }

            Photos
        }
        .task {
            await viewModel.updateUI()
        }
        .padding(.bottom, 16.0.scaled)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            LinearGradient(
                colors: [
                    .color4,
                    .color2
                ],
                startPoint: .top,
                endPoint: .bottom
            )
                .ignoresSafeArea()
        }
        .loadingOverlay
    }

    @ViewBuilder
    private var Photos: some View {
        switch viewModel.photoLibraryStatus {
        case .authorized, .limited:
            GeometryReader { geometryReader in
                let columnsCount = 3
                let spacing: CGFloat = 2.0.scaled
                let totalSpacing = spacing * CGFloat(columnsCount - 1)
                let cell = floor((geometryReader.size.width - totalSpacing) / CGFloat(columnsCount))

                let columns = Array(repeating: GridItem(.fixed(cell), spacing: spacing),
                                    count: columnsCount)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(viewModel.images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: cell, height: cell) // квадрат
                                .clipped()
                                .cornerRadius(8.0.scaled)
                        }
                    }
                }
            }
        case .denied, .restricted:
            VStack(spacing: 12.0.scaled) {
                Text("Allow Photo Access")
                    .foregroundStyle(.color1)
                    .font(.system(size: 15.0.scaled, weight: .bold))
                
                Text("Open Settings to let the app show your photo library")
                    .foregroundStyle(.color1.opacity(0.7))
                    .font(.system(size: 15.0.scaled, weight: .regular))
                    .multilineTextAlignment(.center)
                
                Button("Open Settings") {
                    guard
                        let url = URL(string: UIApplication.openSettingsURLString)
                    else { return }
                    
                    UIApplication.shared.open(url)
                }
                .frame(height: 52.0.scaled)
                .buttonStyle(.glass)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        default:
            ProgressView().controlSize(.large)
        }
    }
    
}
