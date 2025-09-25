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
final class PhotosLibraryViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    
    /*
     MARK: - Properties
     */
    
    @Published
    var images: [UIImage] = []
    
    @Published
    var photoLibraryStatus: PHAuthorizationStatus = .notDetermined

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
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        photoLibraryStatus = status
        
        guard
            status == .authorized || status == .limited
        else { return }

        loadPhotos()
    }

    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        images.removeAll()
        
        let targetSize = CGSize(width: 200.0.scaled, height: 200.0.scaled)

        fetchResult?.enumerateObjects { [weak self] asset, _, _ in
            guard
                let self
            else { return }
            
            let photoConfigurations = PHImageRequestOptions()
            
            photoConfigurations.deliveryMode = .highQualityFormat
            photoConfigurations.resizeMode = .fast
            self.manager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: photoConfigurations
            ) { photo, _ in
                guard
                    let photo
                else { return }
                
                self.images.append(photo)
            }
        }
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard
            let fetchResult,
            let details = changeInstance.changeDetails(for: fetchResult)
        else { return }
        
        self.fetchResult = details.fetchResultAfterChanges
        
        Task { @MainActor in
            self.loadPhotos()
        }
    }
    
}
