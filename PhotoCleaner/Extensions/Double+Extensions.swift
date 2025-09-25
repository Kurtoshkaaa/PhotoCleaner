//
//  Double+Extensions.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import Foundation

extension Double {
    
    var scaled: Double {
        (self * SizeFactor).rounded()
    }

}
