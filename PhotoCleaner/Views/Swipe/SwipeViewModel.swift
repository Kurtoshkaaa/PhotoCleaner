//
//  SwipeViewModel.swift
//  PhotoCleaner
//
//  Created by Codex on 01.07.26.
//

import Photos
import SwiftUI
import Combine

@MainActor
final class SwipeViewModel: ObservableObject {
    
    /*
     MARK: - Properties
     */
    
    @Published
    var photos: [SwipePhotoItem] = []
    
    @Published
    var photoLibraryStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    
    @Published
    var isLoading: Bool = false
    
    @Published
    var currentIndex: Int = 0
    
    @Published
    var markedForDeletionIDs: Set<String> = []
    
    @Published
    var keptIDs: Set<String> = []
    
    @Published
    var deleteErrorMessage: String?
    
    @Published
    var sessionResultMessage: String?
    
    private let manager = PHCachingImageManager.default()
    
    var currentPhoto: SwipePhotoItem? {
        guard
            photos.indices.contains(currentIndex)
        else { return nil }
        
        return photos[currentIndex]
    }
    
    var reviewedCount: Int {
        min(currentIndex, photos.count)
    }
    
    var remainingCount: Int {
        max(photos.count - currentIndex, 0)
    }
    
    var markedForDeletionCount: Int {
        markedForDeletionIDs.count
    }
    
    var keptCount: Int {
        keptIDs.count
    }
    
    var progressTitle: String {
        "\(reviewedCount) / \(photos.count)"
    }
    
    var canFinishSession: Bool {
        reviewedCount > 0 || markedForDeletionCount > 0
    }
    
    /*
     MARK: - Methods
     */
    
    func updateUI() async {
        guard
            !isLoading
        else { return }
        
        sessionResultMessage = nil
        deleteErrorMessage = nil
        isLoading = true
        
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        photoLibraryStatus = status
        
        guard
            status == .authorized || status == .limited
        else {
            photos.removeAll()
            currentIndex = 0
            isLoading = false
            return
        }
        
        await loadPhotos()
        isLoading = false
    }
    
    func keepCurrentPhoto() {
        advanceCurrentPhoto(markedForDeletion: false)
    }
    
    func markCurrentPhotoForDeletion() {
        advanceCurrentPhoto(markedForDeletion: true)
    }
    
    func finishSessionKeepingMarkedPhotos() {
        markedForDeletionIDs.removeAll()
        keptIDs.removeAll()
        currentIndex = 0
        sessionResultMessage = "Session finished. No photos were deleted."
    }
    
    func deleteMarkedPhotos() async {
        let deletedIDs = markedForDeletionIDs
        let assets = photos
            .filter { deletedIDs.contains($0.id) }
            .map(\.asset)
        
        guard
            !assets.isEmpty
        else {
            finishSessionKeepingMarkedPhotos()
            return
        }
        
        isLoading = true
        deleteErrorMessage = nil
        
        let result = await performDeletion(assets: assets)
        isLoading = false
        
        switch result {
        case .success:
            photos.removeAll { item in
                deletedIDs.contains(item.id)
            }
            markedForDeletionIDs.removeAll()
            keptIDs.removeAll()
            currentIndex = 0
            sessionResultMessage = "Deleted \(assets.count) photos."
        case .failure(let error):
            deleteErrorMessage = error.localizedDescription
        }
    }
    
    private func advanceCurrentPhoto(
        markedForDeletion: Bool
    ) {
        guard
            let currentPhoto
        else { return }
        
        sessionResultMessage = nil
        
        if markedForDeletion {
            markedForDeletionIDs.insert(currentPhoto.id)
            keptIDs.remove(currentPhoto.id)
        } else {
            keptIDs.insert(currentPhoto.id)
            markedForDeletionIDs.remove(currentPhoto.id)
        }
        
        currentIndex = min(currentIndex + 1, photos.count)
    }
    
    private func loadPhotos() async {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 80
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(
                key: "creationDate",
                ascending: false
            )
        ]
        
        let result = PHAsset.fetchAssets(
            with: .image,
            options: fetchOptions
        )
        let assets = (0..<result.count).map { index in
            result.object(at: index)
        }
        let targetSize = CGSize(
            width: CGFloat(900.0.scaled),
            height: CGFloat(1200.0.scaled)
        )
        var loadedPhotos: [SwipePhotoItem] = []
        
        for asset in assets {
            guard
                !Task.isCancelled
            else { return }
            
            if let image = await requestImage(
                for: asset,
                targetSize: targetSize
            ) {
                loadedPhotos.append(
                    SwipePhotoItem(
                        asset: asset,
                        image: image
                    )
                )
            }
        }
        
        photos = loadedPhotos
        markedForDeletionIDs.removeAll()
        keptIDs.removeAll()
        currentIndex = 0
    }
    
    private func requestImage(
        for asset: PHAsset,
        targetSize: CGSize
    ) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            
            var didResume = false
            
            manager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                if
                    let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool,
                    isDegraded
                {
                    return
                }
                
                guard
                    !didResume
                else { return }
                
                didResume = true
                continuation.resume(returning: image)
            }
        }
    }
    
    private func performDeletion(
        assets: [PHAsset]
    ) async -> Result<Void, Error> {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assets as NSArray)
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(returning: .failure(error))
                } else if success {
                    continuation.resume(returning: .success(()))
                } else {
                    continuation.resume(returning: .failure(CustomError.custom("Photos could not be deleted.")))
                }
            }
        }
    }
}
