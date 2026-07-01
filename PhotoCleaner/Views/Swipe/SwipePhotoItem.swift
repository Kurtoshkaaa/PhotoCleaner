//
//  SwipePhotoItem.swift
//  PhotoCleaner
//
//  Created by Codex on 01.07.26.
//

import Photos
import UIKit

struct SwipePhotoItem: Identifiable, Hashable {
    
    /*
     MARK: - Properties
     */
    
    let asset: PHAsset
    let image: UIImage
    
    var id: String {
        asset.localIdentifier
    }
    
    var dateTitle: String {
        guard
            let creationDate = asset.creationDate
        else { return "Unknown date" }
        
        return creationDate.formatted(
            date: .abbreviated,
            time: .omitted
        )
    }
    
    var resolutionTitle: String {
        "\(asset.pixelWidth) x \(asset.pixelHeight)"
    }
    
    /*
     MARK: - Methods
     */
    
    static func == (
        lhs: SwipePhotoItem,
        rhs: SwipePhotoItem
    ) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(id)
    }
}
