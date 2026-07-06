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
    
    @State
    private var isSelectionMode: Bool = false
    
    @State
    private var selectedPhotoIDs: Set<String> = []
    
    @State
    private var lastDragSelectedPhotoID: String?
    
    @State
    private var selectionDragState: PhotoSelectionDragState = .idle
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        VStack(spacing: 8.0.scaled) {
            headerView
            
            Photos
        }
        .task {
            await viewModel.updateUI()
        }
        .padding(.top, 8.0.scaled)
        .padding(.bottom, 16.0.scaled)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            PhotoCleanerBackground()
        }
        .overlay(alignment: .top) {
            headerActionsView
        }
        .alert(
            "Could Not Delete Photos",
            isPresented: deleteErrorBinding
        ) {
            Button("OK", role: .cancel) {
                viewModel.deleteErrorMessage = nil
            }
        } message: {
            Text(viewModel.deleteErrorMessage ?? "")
        }
        .onChange(of: viewModel.photos) { _, photos in
            reconcileSelection(with: photos)
        }
        .loadingOverlay
    }
    
    private var headerView: some View {
        HStack(spacing: 2.0.scaled) {
            Text("Library")
                .foregroundStyle(.color1)
                .font(.system(size: 28.0.scaled, weight: .bold))
                .multilineTextAlignment(.center)
            
            LottieView(animation: .named("Photos"))
                .playing(loopMode: .loop)
                .frame(width: 48.0.scaled, height: 48.0.scaled)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var headerActionsView: some View {
        HStack {
            if !selectedPhotoIDs.isEmpty {
                photoActionButton(
                    title: "Delete",
                    tint: PhotoCleanerStyle.deleteAccent,
                    action: handleDeleteSelectedPhotos
                )
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
            
            Spacer()
            
            photoActionButton(
                title: isSelectionMode ? "Cancel" : "Select",
                tint: .color1,
                isLoading: viewModel.isLoading,
                action: handleSelectionModeButton
            )
        }
        .frame(height: 48.0.scaled, alignment: .center)
        .padding(.horizontal, 16.0.scaled)
        .padding(.top, 8.0.scaled)
        .animation(.easeInOut(duration: 0.18), value: isSelectionMode)
        .animation(.easeInOut(duration: 0.18), value: selectedPhotoIDs)
    }
    
    private func photoActionButton(
        title: String,
        tint: Color,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(tint)
                } else {
                    Text(title)
                        .font(.system(size: 17.0, weight: .semibold))
                        .foregroundStyle(tint)
                }
            }
            .frame(width: 70.0.scaled, height: 24.0.scaled)
            .cornerRadius(12.0.scaled)
        }
        .buttonStyle(.glass)
        .disabled(isLoading || viewModel.isLoading)
        .opacity(isLoading || !viewModel.isLoading ? 1.0 : 0.45)
    }
    
    @ViewBuilder
    private var Photos: some View {
        if viewModel.isLoading && viewModel.photos.isEmpty {
            ProgressView()
                .controlSize(.large)
                .tint(.color1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            switch viewModel.photoLibraryStatus {
            case .authorized, .limited:
                if viewModel.photos.isEmpty {
                    emptyLibraryView
                } else {
                    GeometryReader { geometryReader in
                        let columnsCount = 3
                        let spacing: CGFloat = 2.0.scaled
                        let totalSpacing = spacing * CGFloat(columnsCount - 1)
                        let cell = floor((geometryReader.size.width - totalSpacing) / CGFloat(columnsCount))
                        
                        let columns = Array(repeating: GridItem(.fixed(cell), spacing: spacing), count: columnsCount)
                        
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: spacing) {
                                ForEach(viewModel.photos) { photo in
                                    PhotoLibraryGridPhotoView(
                                        photo: photo,
                                        isSelected: selectedPhotoIDs.contains(photo.id),
                                        isSelectionMode: isSelectionMode,
                                        cell: cell
                                    )
                                    .onTapGesture {
                                        handlePhotoTap(photo)
                                    }
                                }
                            }
                            .coordinateSpace(name: photoGridCoordinateSpaceName)
                            .simultaneousGesture(
                                selectionDragGesture(
                                    cell: cell,
                                    spacing: spacing,
                                    columnsCount: columnsCount
                                )
                            )
                        }
                    }
                }
            case .denied, .restricted:
                PhotoCleanerStateCard(
                    imageName: "SplashLogo",
                    systemImage: nil,
                    title: "Photo Access Needed",
                    message: "Allow access so PhotoCleaner can show your library and remove only photos you choose.",
                    buttonTitle: "Open Settings",
                    accent: .color4,
                    action: openSettings
                )
                .padding(.horizontal, 24.0.scaled)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
            default:
                ProgressView()
                    .controlSize(.large)
                    .tint(.color1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private var emptyLibraryView: some View {
        PhotoCleanerStateCard(
            imageName: nil,
            systemImage: "sparkles",
            title: "Nothing to Clean",
            message: "Your photo library has no items available for this session.",
            buttonTitle: nil,
            accent: PhotoCleanerStyle.sparkleAccent,
            action: nil
        )
        .padding(.horizontal, 24.0.scaled)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var deleteErrorBinding: Binding<Bool> {
        Binding {
            viewModel.deleteErrorMessage != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.deleteErrorMessage = nil
            }
        }
    }
    
    private var photoGridCoordinateSpaceName: String {
        "PhotoLibraryGrid"
    }
    
    private func openSettings() {
        guard
            let url = URL(string: UIApplication.openSettingsURLString)
        else { return }
        
        UIApplication.shared.open(url)
    }
    
    /*
     MARK: - Private methods
     */
    
    private func handleSelectionModeButton() {
        if isSelectionMode {
            cancelSelectionMode()
        } else {
            withAnimation(.easeInOut(duration: 0.18)) {
                isSelectionMode = true
            }
        }
    }
    
    private func cancelSelectionMode() {
        withAnimation(.easeInOut(duration: 0.18)) {
            isSelectionMode = false
            selectedPhotoIDs.removeAll()
            lastDragSelectedPhotoID = nil
            selectionDragState = .idle
        }
    }
    
    private func handlePhotoTap(
        _ photo: PhotoLibraryPhotoItem
    ) {
        guard
            isSelectionMode
        else { return }
        
        togglePhotoSelection(photo.id)
    }
    
    private func togglePhotoSelection(
        _ photoID: String
    ) {
        withAnimation(.easeInOut(duration: 0.12)) {
            if selectedPhotoIDs.contains(photoID) {
                selectedPhotoIDs.remove(photoID)
            } else {
                selectedPhotoIDs.insert(photoID)
            }
        }
    }
    
    private func handleDeleteSelectedPhotos() {
        guard
            !selectedPhotoIDs.isEmpty
        else { return }
        
        let photoIDs = selectedPhotoIDs
        
        Task {
            let didDelete = await viewModel.deletePhotos(withIDs: photoIDs)
            
            guard
                didDelete
            else { return }
            
            cancelSelectionMode()
        }
    }
    
    private func reconcileSelection(
        with photos: [PhotoLibraryPhotoItem]
    ) {
        let availablePhotoIDs = Set(photos.map(\.id))
        selectedPhotoIDs.formIntersection(availablePhotoIDs)
        
        if selectedPhotoIDs.isEmpty {
            lastDragSelectedPhotoID = nil
            selectionDragState = .idle
        }
    }
    
    private func selectionDragGesture(
        cell: CGFloat,
        spacing: CGFloat,
        columnsCount: Int
    ) -> some Gesture {
        DragGesture(
            minimumDistance: CGFloat(14.0.scaled),
            coordinateSpace: .named(photoGridCoordinateSpaceName)
        )
        .onChanged { gesture in
            handleSelectionDrag(
                location: gesture.location,
                translation: gesture.translation,
                cell: cell,
                spacing: spacing,
                columnsCount: columnsCount
            )
        }
        .onEnded { _ in
            lastDragSelectedPhotoID = nil
            selectionDragState = .idle
        }
    }
    
    private func handleSelectionDrag(
        location: CGPoint,
        translation: CGSize,
        cell: CGFloat,
        spacing: CGFloat,
        columnsCount: Int
    ) {
        guard
            isSelectionMode
        else { return }
        
        switch selectionDragState {
        case .idle:
            selectionDragState = selectionDragState(for: translation)
        case .selecting, .scrolling:
            break
        }
        
        guard
            selectionDragState == .selecting,
            let photoID = photoID(
                at: location,
                cell: cell,
                spacing: spacing,
                columnsCount: columnsCount
            ),
            photoID != lastDragSelectedPhotoID
        else { return }
        
        selectedPhotoIDs.insert(photoID)
        lastDragSelectedPhotoID = photoID
    }
    
    private func selectionDragState(
        for translation: CGSize
    ) -> PhotoSelectionDragState {
        let horizontalDistance = abs(translation.width)
        let verticalDistance = abs(translation.height)
        let axisThreshold = CGFloat(8.0.scaled)
        
        if verticalDistance > horizontalDistance + axisThreshold {
            return .scrolling
        }
        
        return .selecting
    }
    
    private func photoID(
        at location: CGPoint,
        cell: CGFloat,
        spacing: CGFloat,
        columnsCount: Int
    ) -> String? {
        guard
            location.x >= 0.0,
            location.y >= 0.0
        else { return nil }
        
        let columnWidth = cell + spacing
        let rowHeight = cell + spacing
        let column = Int(location.x / columnWidth)
        let row = Int(location.y / rowHeight)
        let columnOffset = location.x - CGFloat(column) * columnWidth
        let rowOffset = location.y - CGFloat(row) * rowHeight
        
        guard
            column >= 0,
            column < columnsCount,
            columnOffset <= cell,
            rowOffset <= cell
        else { return nil }
        
        let index = row * columnsCount + column
        
        guard
            viewModel.photos.indices.contains(index)
        else { return nil }
        
        return viewModel.photos[index].id
    }
    
}

private enum PhotoSelectionDragState {
    case idle,
         selecting,
         scrolling
}

private struct PhotoLibraryGridPhotoView: View {
    
    /*
     MARK: - Properties
     */
    
    var photo: PhotoLibraryPhotoItem
    var isSelected: Bool
    var isSelectionMode: Bool
    var cell: CGFloat
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        Image(uiImage: photo.image)
            .resizable()
            .scaledToFill()
            .frame(width: cell, height: cell)
            .clipped()
            .overlay {
                if isSelectionMode {
                    Rectangle()
                        .fill(.black.opacity(isSelected ? 0.28 : 0.08))
                }
            }
            .overlay(alignment: .topTrailing) {
                if isSelectionMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? PhotoCleanerStyle.deleteAccent : .color1.opacity(0.86))
                        .font(.system(size: 22.0.scaled, weight: .semibold))
                        .padding(6.0.scaled)
                }
            }
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8.0.scaled)
                        .stroke(PhotoCleanerStyle.deleteAccent, lineWidth: 2.0.scaled)
                }
            }
            .cornerRadius(8.0.scaled)
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.12), value: isSelected)
            .animation(.easeInOut(duration: 0.12), value: isSelectionMode)
    }
}
