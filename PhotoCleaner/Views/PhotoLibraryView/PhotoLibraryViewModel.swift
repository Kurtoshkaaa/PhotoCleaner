//
//  PhotosLibraryViewModel.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 25.09.25.
//

import SwiftUI
import Photos
import Combine

@MainActor
final class PhotosLibraryViewModel: NSObject, ObservableObject {
    
    /*
     MARK: - Properties
     */
    
    @Published
    var photos: [PhotoLibraryPhotoItem] = []
    
    @Published
    var photoLibraryStatus: PHAuthorizationStatus = .notDetermined
    
    @Published
    var deleteErrorMessage: String?
    
    @Published
    var isLoading: Bool = false

    private let manager = PHCachingImageManager.default()
    private var fetchResult: PHFetchResult<PHAsset>?

    /*
     MARK: - Life circle
     */
    
    override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    /*
     MARK: - Methods
     */
    
    func updateUI() async {
        guard
            !isLoading
        else { return }
        
        isLoading = true
        deleteErrorMessage = nil
        
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        photoLibraryStatus = status
        
        guard
            status == .authorized || status == .limited
        else {
            photos.removeAll()
            isLoading = false
            return
        }

        await loadPhotos()
        isLoading = false
    }
    
    func deletePhotos(
        withIDs selectedPhotoIDs: Set<String>
    ) async -> Bool {
        let assets = photos
            .filter { selectedPhotoIDs.contains($0.id) }
            .map(\.asset)
        
        guard
            !assets.isEmpty
        else { return false }
        
        isLoading = true
        deleteErrorMessage = nil
        
        let result = await performDeletion(assets: assets)
        isLoading = false
        
        switch result {
        case .success:
            photos.removeAll { item in
                selectedPhotoIDs.contains(item.id)
            }
            return true
        case .failure(let error):
            deleteErrorMessage = error.localizedDescription
            return false
        }
    }

    private func loadPhotos() async {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        let assets = (0..<(fetchResult?.count ?? 0)).compactMap { index in
            fetchResult?.object(at: index)
        }
        let targetSize = CGSize(
            width: CGFloat(240.0.scaled),
            height: CGFloat(240.0.scaled)
        )
        var loadedPhotos: [PhotoLibraryPhotoItem] = []

        for asset in assets {
            guard
                !Task.isCancelled
            else { return }
            
            if let image = await requestImage(
                for: asset,
                targetSize: targetSize
            ) {
                loadedPhotos.append(
                    PhotoLibraryPhotoItem(
                        asset: asset,
                        image: image
                    )
                )
            }
        }
        
        photos = loadedPhotos
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
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension PhotosLibraryViewModel: PHPhotoLibraryChangeObserver {
    
    nonisolated func photoLibraryDidChange(
        _ changeInstance: PHChange
    ) {
        Task { @MainActor [weak self] in
            guard
                let self,
                let fetchResult,
                let details = changeInstance.changeDetails(for: fetchResult)
            else { return }
            
            self.fetchResult = details.fetchResultAfterChanges
            await self.loadPhotos()
        }
    }
}

struct PhotoLibraryPhotoItem: Identifiable, Hashable {
    
    /*
     MARK: - Properties
     */
    
    let asset: PHAsset
    let image: UIImage
    
    var id: String {
        asset.localIdentifier
    }
    
    /*
     MARK: - Methods
     */
    
    static func == (
        lhs: PhotoLibraryPhotoItem,
        rhs: PhotoLibraryPhotoItem
    ) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(id)
    }
}
